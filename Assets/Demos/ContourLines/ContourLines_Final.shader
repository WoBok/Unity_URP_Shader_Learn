Shader "URP Shader/ContourLines 2" {
    Properties {
        [HDR]_BaseColor ("Color", Color) = (1, 1, 1, 1)
        _RandomOffset ("Random Offset", Float) = 0

        _Line1Color ("Line 1 Color", Color) = (1, 1, 1, 1)
        _Line1Mask ("Line 1 Tex", 2D) = "white" { }
        _Line1Speed ("Line 1 Speed", Float) = 0
        _Line1Frequency ("Line 1 Frequency", Float) = 100
        _Line1Alpha ("Line 1 Alpha", Range(0, 10)) = 0.2

        _Line2Mask ("Line 2 Tex", 2D) = "white" { }
        _Line2Speed ("Line 2 Speed", Float) = 0
        _Line2Frequency ("Line 2 Frequency", Float) = 100
        _Line2Alpha ("Line 2 Alpha", Range(0, 100)) = 0.2

        [HDR]_FresnelColor ("Fresenl Color", Color) = (1, 1, 1, 1)
        _FresnelPower ("Fresenl Power", Float) = 1

        _NoiseColor ("Noise Color", Color) = (1, 1, 1, 1)
        _NoiseSpeed ("Noise Speed", Float) = 1
        _NoiseScale ("Noise Scale", Float) = 100

        // x:速度，y:抖动范围，z:抖动偏移量，w:频率(0~0.99)
        _HologramGliterData1 ("Hologram Gliter Data1", Vector) = (0, 1, 0, 0)
        _HologramGliterData2 ("Hologram Gliter Data2", Vector) = (0, 1, 0, 0)
        _HologramGliterData3 ("Hologram Gliter Data3", Vector) = (0, 1, 0, 0)

        _AlphaMask ("Alpha Mask", 2D) = "white" { }

        _FadeHight ("Fade Hight", Float) = 0.2
        _RandomHightFactor ("Random Hight Factor", Float) = 0

        _MaskCenter ("Mask Center", Vector) = (0, 0, 0, 0)
        _MaskSize ("Mask Size", Vector) = (0, 0, 0, 0)
        _Falloff ("Falloff", Float) = 0

        _Alpha ("Alpha", Range(0, 1)) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" }

        Pass {

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings {
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float4 positionCS : SV_POSITION;
                float3 positionOS : TEXCOORD2;
                float3 positionWS : TEXCOORD3;
            };
            
            sampler2D _Line1Mask;
            sampler2D _Line2Mask;
            sampler2D _AlphaMask;
            CBUFFER_START(UnityPerMaterial)
            float4 _Line1Mask_ST;
            float4 _Line2Mask_ST;

            float4 _BaseColor;

            float _RandomOffset;

            float _Line1Speed;
            float _Line1Frequency;
            float _Line1Alpha;

            float _Line2Speed;
            float _Line2Frequency;
            float _Line2Alpha;

            float4 _FresnelColor;
            float _FresnelPower;

            float4 _NoiseColor;
            float _NoiseSpeed;
            float _NoiseScale;

            float4 _HologramGliterData1;
            float4 _HologramGliterData2;
            float4 _HologramGliterData3;

            float _FadeHight;
            float _RandomHightFactor;

            float _XClip;
            float _ZClip;
            float _RandomClipFactor;

            float4 _MaskCenter;
            float4 _MaskSize;
            float _Falloff;

            float _Alpha;
            CBUFFER_END

            float ContourLine(sampler2D lineTexture, float position, float lineOffset, float lineSpeed, float lineFrequency) {
                float offset = lineSpeed * _Time.y + lineOffset;
                float offsetAndScale = position * lineFrequency + offset;
                float4 lineMask = tex2D(lineTexture, offsetAndScale);
                return lineMask.r;
            }

            float Fresnel(float3 normal, float3 viewDir, float power) {
                return pow((1.0 - saturate(dot(normalize(normal), normalize(viewDir)))), power);
            }

            float2 GradientNoise_Dir(float2 p) {
                p = p % 289;
                float x = (34 * p.x + 1) * p.x % 289 + p.y;
                x = (34 * x + 1) * x % 289;
                x = frac(x / 41) * 2 - 1;
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }

            float GradientNoise(float2 p) {
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(GradientNoise_Dir(ip), fp);
                float d01 = dot(GradientNoise_Dir(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(GradientNoise_Dir(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(GradientNoise_Dir(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
            }

            float GenerateGradientNoise(float2 uv, float scale) {
                return GradientNoise(uv * scale) + 0.5;
            }

            float4 GradientNoiseColor(float2 uv, float4 noiseColor) {
                float2 noiseUV = _Time.y * _NoiseSpeed + uv;
                return GenerateGradientNoise(noiseUV, _NoiseScale) * noiseColor;
            }

            float3 VertexHologramOffset(float3 vertex, float4 offsetData) {
                float speed = offsetData.x;
                float range = offsetData.y;
                float offset = offsetData.z;
                float frequency = offsetData.w;

                float offset_time = sin(_Time.y * speed);
                float timeToGliter = step(frequency, offset_time);
                float gliterPosY = sin(vertex.y + _Time.z);
                float gliterPosYRange = step(0, gliterPosY) * step(gliterPosY, range);
                float res = gliterPosYRange * offset * timeToGliter * gliterPosY;
                float3 view_offset = float3(res, 0, 0);

                return mul((float3x3)UNITY_MATRIX_T_MV, view_offset);
            }

            float Random(float2 uv) {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float Mask(float3 positionWS, float3 center, float3 size, float falloff) {
                float3 offset = abs(positionWS - center);
                offset -= size;
                offset = max(float3(0, 0, 0), offset);
                float dis = distance(offset, float3(0, 0, 0));
                return dis /= falloff;
            }

            Varyings Vertex(Attributes input) {
                Varyings output;
                
                float4 positionOS = input.positionOS;

                positionOS.xyz += VertexHologramOffset(positionOS.xyz, _HologramGliterData1);
                positionOS.xyz += VertexHologramOffset(positionOS.xyz, _HologramGliterData2);
                positionOS.xyz += VertexHologramOffset(positionOS.xyz, _HologramGliterData3);

                output.positionCS = mul(UNITY_MATRIX_MVP, positionOS);
                output.positionOS = input.positionOS.xyz;
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                
                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));

                output.uv = input.texcoord;

                return output;
            }

            float4 Fragment(Varyings input) : SV_Target {
                half4 diffuse = dot(input.normalWS, normalize(_MainLightPosition.xyz)) * 0.5 + 0.5;
                float4 color = diffuse * _BaseColor;

                float line1 = ContourLine(_Line1Mask, input.positionOS.y, _RandomOffset, _Line1Speed, _Line1Frequency);
                float4 line1Color = color * line1;
                line1Color.a = _Line1Alpha * line1;

                float line2 = ContourLine(_Line2Mask, input.positionOS.y, _RandomOffset, _Line2Speed, _Line2Frequency);
                float4 line2Color = color * line2;
                line2Color.a = _Line2Alpha * line2;

                float4 lineColor = line1Color * line2Color;
                lineColor.a += line1Color.a;

                float3 viewDirWS = _WorldSpaceCameraPos - input.positionWS;
                float4 fresnelColor = Fresnel(input.normalWS, viewDirWS, _FresnelPower) * _FresnelColor;

                float4 noiseColor = GradientNoiseColor(input.uv, _NoiseColor);

                float4 finalColor = color + lineColor + fresnelColor + noiseColor;

                float alphaMask = tex2D(_AlphaMask, input.uv).r;

                float randomValue = Random(input.uv * _Time.y);

                float fadeAlpha = step(input.positionOS.y, _FadeHight + randomValue * _RandomHightFactor);

                finalColor.a *= alphaMask * fadeAlpha ;

                float mask = Mask(input.positionWS, _MaskCenter, _MaskSize, _Falloff);
                mask = clamp(mask, 0, 1);
                finalColor.a *= (1 - mask);

                finalColor.a *= _Alpha;

                return finalColor;
            }
            ENDHLSL
        }
    }
}