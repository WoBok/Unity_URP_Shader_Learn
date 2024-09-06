Shader "URP Shader/PBR" {
    Properties {
        _BaseMap ("Base Map", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _MetallicMap ("Metallic Map", 2D) = "white" { }
        _Smoothness ("Smoothness", Range(0, 1)) = 0

        [Header(Normal)]
        [Toggle]_NormalSwitch ("Normal Switch", Int) = 0.

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
            #pragma shader_feature_local _NORMALSWITCH_ON

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
                #ifdef _NORMALSWITCH_ON
                    half4 normalWS : TEXCOORD2;     //w: viewDirctionWS.x
                    half4 tangentWS : TEXCOORD3;     //w: viewDirctionWS.y
                    half4 bitangentWS : TEXCOORD4;     //w: viewDirctionWS.z
                #else
                    half3 normalWS : TEXCOORD2;
                #endif
                float4 positionCS : SV_POSITION;
            };
            
            sampler2D _BaseMap;
            sampler2D _MetallicMap;
            #ifdef _NORMALSWITCH_ON
                sampler2D _NormalMap;
            #endif
            sampler2D _OcclusionMap;

            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;

            #ifdef _NORMALSWITCH_ON
                float _NormalScale;
            #endif
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);
                output.positionWS = mul(UNITY_MATRIX_M, input.positionOS);

                half3 normalWS = normalize(mul(input.normalOS, (float3x3)UNITY_MATRIX_I_M));
                #ifdef _NORMALSWITCH_ON
                    half3 viewDirctionWS = _WorldSpaceCameraPos - output.positionWS;
                    output.normalWS = half4(normalWS, viewDirctionWS.x);
                    half3 tangentWS = normalize(mul((float3x3)UNITY_MATRIX_M, input.tangentOS.xyz));
                    output.tangentWS = half4(tangentWS, viewDirctionWS.y);
                    half3 bitangentWS = cross(normalWS, tangentWS) * input.tangentOS.w;
                    output.bitangentWS = half4(bitangentWS, viewDirctionWS.z);
                #else
                    output.normalWS = normalize(normalWS);
                #endif

                output.uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                half4 albedo = tex2D(_BaseMap, input.uv);
                #ifdef _NORMALSWITCH_ON
                    half4 normalTS = UnpackNormal(tex2D(_NormalMap, input.uv));
                    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
                    half4 normalWS = mul(normalTS, tangentToWorld);
                #endif

                half4 diffuse = albedo * (dot(input.normalWS, normalize(_MainLightPosition.xyz)) * 0.5 + 0.5);

                return diffuse * _BaseColor;
            }
            ENDHLSL
        }
    }
}