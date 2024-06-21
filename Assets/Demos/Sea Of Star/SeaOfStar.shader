Shader "URP Shader/SeaOfStar" {
    Properties {
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
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
            };

            struct Varyings {
                float4 positionCS : SV_POSITION;
            };
            
            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
            CBUFFER_END

            Varyings Vertex(Attributes input) {
                Varyings output;
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);
                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {
                return _BaseColor;
            }
            ENDHLSL
        }
    }
}