Shader "URP Shader/ColorMask" {
    Properties {
        _NoiseMap ("Albedo", 2D) = "white" { }
        _Visibility ("Visibility", Range(0, 1)) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry-1445" }

        Cull Off
        ZTest Off
        ColorMask 0

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
            
            sampler2D _NoiseMap;
            CBUFFER_START(UnityPerMaterial)
            float4 _NoiseMap_ST;
            half _Visibility;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);

                output.uv = input.texcoord.xy * _NoiseMap_ST.xy + _NoiseMap_ST.zw;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                half noise = tex2D(_NoiseMap, input.uv).r;

                clip(noise - _Visibility);

                return half4(0, 0, 0, noise);
            }
            ENDHLSL
        }
    }
}