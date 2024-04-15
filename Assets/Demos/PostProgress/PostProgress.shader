Shader "URP Shader/PostProgress" {
    Properties {
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
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);
                
                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                return half4(1, 1, 0, 1);
            }
            ENDHLSL
        }
    }
}