Shader "URP Shader/CommonFunction_Floor or Ceil" {
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
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };
            
            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);

                output.uv = input.texcoord;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                float2 uv = input.uv;

                uv *= 10;
                //float2 integer = floor(uv);
                float2 integer = ceil(uv); //可看作二位图案数组的索引
                integer /= 10;

                half4 color = float4(integer.x, integer.y, 0, 1);

                return color;
            }
            ENDHLSL
        }
    }
}