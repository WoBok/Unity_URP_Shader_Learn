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
        _Line2Alpha ("Line 2 Alpha", Range(0, 10)) = 0.2

        [HDR]_FresnelColor ("Fresenl Color", Color) = (1, 1, 1, 1)
        _FresnelPower ("Fresenl Power", Float) = 1

        _NoiseColor ("Noise Color", Color) = (1, 1, 1, 1)
        _NoiseSpeed ("Noise Speed", Float) = 1
        _NoiseScale ("Noise Scale", Float) = 100

        _VibrationNoiseTitll ("Vibration Noise Titll", Float) = 1
        _VibrationNoiseOffset ("Vibration Noise Offset", Float) = 0.02
        _VibrationNoiseScale ("Vibration Noise Scale", Float) = 1.0

        _A ("A", Float) = 1
        _B ("B", Float) = 1
        _C ("C", Float) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {

            Blend SrcAlpha OneMinusSrcAlpha

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
            CBUFFER_START(UnityPerMaterial)
            float4 _Line1Mask_ST;
            float4 _Line2Mask_ST;

            half4 _BaseColor;

            float _RandomOffset;

            float _Line1Speed;
            float _Line1Frequency;
            float _Line1Alpha;

            float _Line2Speed;
            float _Line2Frequency;
            float _Line2Alpha;

            half4 _FresnelColor;
            float _FresnelPower;

            half4 _NoiseColor;
            float _NoiseSpeed;
            float _NoiseScale;

            float _VibrationNoiseTitll;

            float _VibrationNoiseOffset;
            float _VibrationNoiseScale;
            float _A;
            float _B;
            float _C;
            CBUFFER_END

            half ContourLine(sampler2D lineTexture, float position, float lineOffset, float lineSpeed, float lineFrequency) {
                float offset = lineSpeed * _Time.y + lineOffset;
                float offsetAndScale = position * lineFrequency + offset;
                half4 lineMask = tex2D(lineTexture, offsetAndScale);
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

            half4 GradientNoiseColor(float2 uv, half4 noiseColor) {
                float2 noiseUV = _Time.y * _NoiseSpeed + uv;
                return GenerateGradientNoise(noiseUV, _NoiseScale) * noiseColor;
            }

            Varyings Vertex(Attributes input) {
                Varyings output;
                
                float4 positionOS = input.positionOS;
                positionOS.xy += GenerateGradientNoise(input.texcoord * _VibrationNoiseTitll + _Time.y * _VibrationNoiseOffset, _VibrationNoiseScale) * step(_A, sin(_Time.y*_C) * _B)*0.1;

                output.positionCS = mul(UNITY_MATRIX_MVP, positionOS);
                output.positionOS = input.positionOS;
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                
                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));

                output.uv = input.texcoord;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {
                half4 diffuse = dot(input.normalWS, normalize(_MainLightPosition.xyz)) * 0.5 + 0.5;
                half4 color = diffuse * _BaseColor;

                float line1 = ContourLine(_Line1Mask, input.positionOS.z, _RandomOffset, _Line1Speed, _Line1Frequency);
                half4 line1Color = color * line1;
                line1Color.a = _Line1Alpha * line1;

                float line2 = ContourLine(_Line2Mask, input.positionOS.z, _RandomOffset, _Line2Speed, _Line2Frequency);
                half4 line2Color = color * line2;
                line2Color.a = _Line2Alpha * line2;

                half4 lineColor = line1Color * line2Color;
                lineColor.a += line1Color.a;

                half3 viewDirWS = _WorldSpaceCameraPos - input.positionWS;
                half4 fresnelColor = Fresnel(input.normalWS, viewDirWS, _FresnelPower) * _FresnelColor;

                half4 noiseColor = GradientNoiseColor(input.uv, _NoiseColor);

                return color + lineColor + fresnelColor + noiseColor;
            }
            ENDHLSL
        }
    }
}