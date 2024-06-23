Shader "URP Shader/Distance" {
    Properties { }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float2 texcoord : TEXCOORD0;
                float4 positionOS : POSITION;
            };

            struct Varyings {
                float2 uv : TEXCOORD0;
                float3 scale : TEXCOORD1;
                float4 positionCS : SV_POSITION;
            };
            
            Varyings Vertex(Attributes input) {

                Varyings output;
                
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);

                output.uv = input.texcoord;

                output.scale = float3(UNITY_MATRIX_M[0][0], UNITY_MATRIX_M[1][1], UNITY_MATRIX_M[2][2]);

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {
                float2 uv = input.uv * 2 - 1;

                half4 color;

                //≈∑ œæ‡¿Î
                //half d = sqrt(pow(uv.x, 2) + pow(uv.y, 2));

                //¬¸π˛∂Ÿæ‡¿Î
                //half d = abs(uv.x) + abs(uv.y);

                //«–±»—©∑Úæ‡¿Î
                //half d = max(abs(uv.x), abs(uv.y));

                //¬Ì œæ‡¿Î
                half aspect = input.scale.x / input.scale.y ;
                half d = sqrt(pow(uv.x * aspect, 2) + pow(uv.y, 2));

                color = half4(d, d, d, 1);

                return color;
            }
            ENDHLSL
        }
    }
}