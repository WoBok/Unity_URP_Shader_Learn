Shader "Demo/Cloud" {
    Properties {
        _SharpTex ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _Threshold ("Threshold", Range(0, 1)) = 1
        _BillboardScale ("Billboard Scale", Range(0, 5)) = 2.5
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
                float4 texcoord : TEXCOORD0;
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
            float _BillboardScale;
            CBUFFER_END

            float4 Remap(float4 In, float2 InMinMax, float2 OutMinMax) {
                return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            float4 VaryPosition(float4 uv, float4 positionOS) {
                float4 remapUV = Remap(uv, float2(0, 1), float2(-1, 1));
                float4 viewUV = mul(remapUV, UNITY_MATRIX_V);
                float4 modelUV = mul(viewUV, UNITY_MATRIX_M);

                //float3 _Object_Scale = float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                //length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                //length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z)));

                //float3 scaledModelUV = mul(modelUV, _Object_Scale);

                modelUV = normalize(modelUV);
                modelUV *= _BillboardScale;
                modelUV = positionOS+modelUV;
                return modelUV;
            }


            Varyings Vertex(Attributes input) {

                Varyings output;
                
                float4 variedPosition=VaryPosition(input.texcoord,input.positionOS);

                output.positionCS = mul(UNITY_MATRIX_MVP, variedPosition);
                
                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));

                output.uv = input.texcoord.xy * _SharpTex_ST.xy + _SharpTex_ST.zw;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                half4 alphaTest = tex2D(_SharpTex, input.uv).a;

                half4 diffuse = (dot(input.normalWS, normalize(_MainLightPosition.xyz)) * 0.5 + 0.5);

                half4 color = diffuse;

                clip(alphaTest - _Threshold);

                color.a = alphaTest;

                return color;
            }
            ENDHLSL
        }
    }
}