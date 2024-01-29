Shader "URP Shader/ContourLines" {
    Properties {
        [HDR]_BaseColor ("Color", Color) = (1, 1, 1, 1)

        [HDR]_FresnelColor ("Fresenl Color", Color) = (1, 1, 1, 1)
        _FresnelPower ("Fresenl Power", Float) = 1

        _FadeHight ("Fade Hight", Float) = 0.2

        _MaskCenter ("Mask Center", Vector) = (0, 0, 0, 0)
        _MaskSize ("Mask Size", Vector) = (0, 0, 0, 0)
        _Falloff ("Falloff", Float) = 0

        _LightPosition ("Light Position", Vector) = (0.3, 0.1, 0.1, 1)

        _LineFrequency ("Line Frequency", Float) = 1
        _LineWidth ("Line Width", Float) = 0.01
        _LineAlpha ("Line Alpha", Range(0, 10)) = 0.2

        _RGB ("RGB", Range(0, 1)) = 1
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
                float4 color : COLOR;
            };

            struct Varyings {
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float4 positionCS : SV_POSITION;
                float3 positionOS : TEXCOORD2;
                float3 positionWS : TEXCOORD3;
                float4 color : COLOR;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _BaseColor;

            float4 _FresnelColor;
            float _FresnelPower;

            float _FadeHight;

            float4 _MaskCenter;
            float4 _MaskSize;
            float _Falloff;

            float3 _LightPosition;

            float _LineFrequency;
            float _LineWidth;
            float _LineAlpha;
            
            float _RGB;
            float _Alpha;
            CBUFFER_END

            float Fresnel(float3 normal, float3 viewDir, float power) {
                return pow((1.0 - saturate(dot(normalize(normal), normalize(viewDir)))), power);
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

                output.color = input.color;

                return output;
            }

            float4 Fragment(Varyings input) : SV_Target {
                half4 diffuse = dot(input.normalWS, normalize(_LightPosition)) * 0.5 + 0.5;
                float4 color = diffuse * _BaseColor;
                color.a = input.color.a;

                float lineFactor = step(frac(input.positionOS.y * _LineFrequency), _LineWidth);
                float4 lineColor = color * lineFactor;
                lineColor.a = _LineAlpha * lineFactor;

                float3 viewDirWS = _WorldSpaceCameraPos - input.positionWS;
                float4 fresnelColor = Fresnel(input.normalWS, viewDirWS, _FresnelPower) * _FresnelColor;
                fresnelColor.rgb *= _RGB;

                float4 finalColor = color + lineColor + fresnelColor;
                finalColor.rgb *= _RGB;

                float fadeAlpha = step(input.positionOS.y, _FadeHight);
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