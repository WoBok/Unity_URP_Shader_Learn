Shader "URP Shader/Outline_RenderFeature" {
    Properties {
        _Outline ("Outline", Range(0, 1)) = 0.1
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Cull Front

        Pass {
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings {
                float4 positionCS : SV_POSITION;
            };
            
            sampler2D _BaseMap;
            CBUFFER_START(UnityPerMaterial)
            float _Outline;
            half4 _OutlineColor;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                float4 position = mul(UNITY_MATRIX_MV, input.positionOS);
                float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, input.normalOS);
                normal.z = -0.5;
                position = position + float4(normalize(normal), 0) * _Outline;
                output.positionCS = mul(UNITY_MATRIX_P, position);

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {
                return _OutlineColor;
            }
            ENDHLSL
        }
    }
}