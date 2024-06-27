Shader "URP Shader/CommonFunction_Fmod" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }

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
            
            sampler2D _BaseMap;
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);

                output.uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                float2 uv = input.uv;

                uv *= 10;

                //小数做除法，除不尽留下的余数
                //此处循环的值的区间为[0,0.4]，乘以2.5使其区间为[0,1]
                float2 remainder = fmod(uv, 0.4) * 2.5;

                half4 color = float4(remainder.x, remainder.y, 0, 1);

                return color;
            }
            ENDHLSL
        }
    }
}