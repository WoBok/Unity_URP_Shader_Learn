Shader "URP Shader/PBR" {
    Properties {
        _BaseMap ("Base Map", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _MetallicMap ("Metallic Map", 2D) = "white" { }
        _Smoothness ("Smoothness", Range(0, 1)) = 0
        _NormalMap ("Normal Map", 2D) = "white" { }
        _NormalScale ("Normal Scale", Float) = 1
        _OcclusionMap ("Occlusion Map", 2D) = "white" { }
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
                float4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float4 positionCS : SV_POSITION;
                float4 TtoW0 : TEXCOORD3;
                float4 TtoW1 : TEXCOORD4;
                float4 TtoW2 : TEXCOORD5;
            };
            
            sampler2D _BaseMap;
            sampler2D _MetallicMap;
            sampler2D _NormalMap;
            sampler2D _OcclusionMap;

            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);
                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));
                output.uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;

                half3 worldTangent = normalize(mul((float3x3)UNITY_MATRIX_M, input.tangentOS.xyz));
                half3 worldBinormal = cross(output.normalWS, worldTangent) * input.tangentOS.w;
                output.TtoW0 = float4(worldTangent.x, worldBinormal.x, output.normalWS.x, output.positionWS.x);
                output.TtoW1 = float4(worldTangent.y, worldBinormal.y, output.normalWS.y, output.positionWS.y);
                output.TtoW2 = float4(worldTangent.z, worldBinormal.z, output.normalWS.z, output.positionWS.z);

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                half4 albedo = tex2D(_BaseMap, input.uv);

                half4 diffuse = albedo * (dot(input.normalWS, normalize(_MainLightPosition.xyz)) * 0.5 + 0.5);

                return diffuse * _BaseColor;
            }
            ENDHLSL
        }
    }
}