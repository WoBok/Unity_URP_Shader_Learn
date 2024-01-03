Shader "URP Shader/Lit" {
    Properties {
        [MainTexture] _BaseMap ("Albedo", 2D) = "white" { }
        [MainColor] _BaseColor ("Color", Color) = (1, 1, 1, 1)
        [Toggle]NormalMap ("Enable Normal Map", int) = 1
        _BumpMap ("Normal Map", 2D) = "bump" { }
        _BumpScale ("Scale", Float) = 1.0
        [HDR] _Emission ("Emission", Color) = (0, 0, 0, 0)
        _Smoothness ("Smoothness", Range(0, 1)) = 0
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Occlusion ("Occlusion", Range(0, 1)) = 1

        [HideInInspector]_QueueOffset ("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl ("_QueueControl", Float) = -1
    }

    SubShader {

        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {

            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM

            #pragma target 4.5

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_ON

            #pragma shader_feature NORMALMAP_ON

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
                float2 staticLightmapUV : TEXCOORD1;
            };

            struct Varyings {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 viewDirWS : TEXCOORD3;
                float4 shadowCoord : TEXCOORD4;
                float4 tangentWS : TEXCOORD5;
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);

                float4 positionCS : SV_POSITION;
            };
            
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_BumpMap);
            SAMPLER(sampler_BumpMap);
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            float _BumpScale;
            half4 _Emission;
            float _Smoothness;
            float _Metallic;
            float _Occlusion;
            CBUFFER_END

            void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData) {
                half3 viewDirWS = _WorldSpaceCameraPos - input.positionWS;

                inputData = (InputData)0;
                inputData.positionWS = input.positionWS;
                inputData.viewDirectionWS = normalize(viewDirWS);
                inputData.shadowCoord = input.shadowCoord;
                inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
                
                #ifdef NORMALMAP_ON
                    float3 bitangent = input.tangentWS.w * cross(input.normalWS.xyz, input.tangentWS.xyz);
                    half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
                    inputData.tangentToWorld = tangentToWorld;
                    inputData.normalWS = TransformTangentToWorld(normalTS, tangentToWorld);
                #else
                    inputData.normalWS = normalize(input.normalWS);
                #endif
            }

            void InitializeSurfaceData(float2 uv, out SurfaceData outSurfaceData) {
                half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                half4 packedNormal = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv);
                half3 normalTS;
                normalTS.xy = packedNormal.ag * 2.0 - 1.0 ;
                normalTS.z = max(1.0e-16, sqrt(1.0 - saturate(dot(normalTS.xy, normalTS.xy))));
                //normalTS.z = sqrt(1 - saturate(dot(normalTS.xy, normalTS.xy)));

                outSurfaceData = (SurfaceData)0;
                outSurfaceData.albedo = albedo.rgb * _BaseColor.rgb;
                outSurfaceData.metallic = _Metallic;
                outSurfaceData.smoothness = _Smoothness;
                outSurfaceData.emission = _Emission.rgb;
                outSurfaceData.occlusion = _Occlusion;
                outSurfaceData.normalTS = normalTS;
            }

            Varyings Vertex(Attributes input) {
                Varyings output = (Varyings)0;

                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.shadowCoord = TransformWorldToShadowCoord(output.positionWS);
                output.positionCS = TransformWorldToHClip(output.positionWS);

                half sign = input.tangentOS.w * unity_WorldTransformParams.w >= 0.0 ?   1.0 : - 1.0;
                half4 tangentWS = half4(TransformObjectToWorldDir(input.tangentOS.xyz), sign);
                output.tangentWS = tangentWS;

                OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {
                SurfaceData surfaceData ;
                InitializeSurfaceData(input.uv, surfaceData);

                InputData inputData;
                InitializeInputData(input, surfaceData.normalTS, inputData);

                half4 color = UniversalFragmentPBR(inputData, surfaceData);

                return color;
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
    CustomEditor "UnityEditor.ShaderGraphLitGUI"
}