Shader "URP Shader/Grid" {
    Properties {
        _BackgroundColor ("Background Color", Color) = (0, 0, 0, 0)
        _LineColor ("Line Color", Color) = (0, 1, 0, 0)
        _Size ("Size", float) = 2
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
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
            };
            
            CBUFFER_START(UnityPerMaterial)
            half4 _BackgroundColor;
            half4 _LineColor;
            float _Size;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);
                
                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));

                output.uv = input.texcoord.xy;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {
                float4 color;

                float2 aspect = float2(2, 1);
                float2 uv = input.uv * _Size * aspect;
                
                float2 gv = frac(uv) - 0.5;

                float xFactor = step(gv.x, 0.48);
                float yFactor = step(gv.y, 0.49);

                color = lerp(_LineColor, _BackgroundColor, xFactor * yFactor);

                return color;
            }
            ENDHLSL
        }
    }
}