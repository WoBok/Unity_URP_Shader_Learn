Shader "URP Shader/ContourLines Opt" {
    Properties {
        [HDR]_BaseColor ("Color", Color) = (1, 1, 1, 1)
        _RandomOffset ("Random Offset", Float) = 0

        _Line1Alpha ("Line 1 Alpha", Range(0, 10)) = 0.2

        [HDR]_FresnelColor ("Fresenl Color", Color) = (1, 1, 1, 1)
        _FresnelPower ("Fresenl Power", Float) = 1

        _FadeHight ("Fade Hight", Float) = 0.2
        _RandomHightFactor ("Random Hight Factor", Float) = 0

        _MaskCenter ("Mask Center", Vector) = (0, 0, 0, 0)
        _MaskSize ("Mask Size", Vector) = (0, 0, 0, 0)
        _Falloff ("Falloff", Float) = 0

        _Alpha ("Alpha", Range(0, 1)) = 1

        _LineInterval ("Line Interval", float) = 1
        _LineWidth ("Line Wdiht", float) = 0.2
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
            CBUFFER_START(UnityPerMaterial)
            float4 _Line1Mask_ST;
            float4 _Line2Mask_ST;

            float4 _BaseColor;

            float _RandomOffset;

            float _Line1Frequency;
            float _Line1Alpha;

            float4 _FresnelColor;
            float _FresnelPower;

            float _FadeHight;
            float _RandomHightFactor;

            float4 _MaskCenter;
            float4 _MaskSize;
            float _Falloff;

            float _Alpha;
            float _LineInterval;
            float _LineWidth;
            CBUFFER_END

            float Fresnel(float3 normal, float3 viewDir, float power) {
                return pow((1.0 - saturate(dot(normalize(normal), normalize(viewDir)))), power);
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

                float line1 = step(frac((input.positionOS.y * _RandomOffset) / _LineInterval), _LineWidth);
                float4 line1Color = color * line1;
                line1Color.a = _Line1Alpha * line1;

                float4 lineColor = line1Color;
                lineColor.a += line1Color.a;

                float3 viewDirWS = _WorldSpaceCameraPos - input.positionWS;
                float4 fresnelColor = Fresnel(input.normalWS, viewDirWS, _FresnelPower) * _FresnelColor;

                float4 finalColor = color + lineColor + fresnelColor ;

                float randomValue = Random(input.uv * _Time.y);

                float fadeAlpha = step(input.positionOS.y, _FadeHight + randomValue * _RandomHightFactor);

                finalColor.a *= fadeAlpha ;

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