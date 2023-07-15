Shader "Demo/Cloud" {
    Properties {
        _SharpTex ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _Threshold("Threshold",Range(0,1))=1
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
            
            sampler2D _SharpTex;
            CBUFFER_START(UnityPerMaterial)
            float4 _SharpTex_ST;
            half4 _BaseColor;
            float _Threshold;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);
                
                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));

                output.uv = input.texcoord.xy * _SharpTex_ST.xy + _SharpTex_ST.zw;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                half4 alphaTest = tex2D(_SharpTex, input.uv).a;

                half4 diffuse =  (dot(input.normalWS, normalize(_MainLightPosition.xyz)) * 0.5 + 0.5);

                half4 color = diffuse;

                clip(alphaTest - _Threshold);

                color.a = alphaTest;

                return color;
            }
            ENDHLSL
        }
    }
}