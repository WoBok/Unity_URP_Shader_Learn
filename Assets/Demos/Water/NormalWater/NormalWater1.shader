Shader "URP Shader/NormalWater1" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)

        [Header(PBR)]
        [Space(5)]
        _Smoothness ("Smoothness", Range(0, 1)) = 0
        _Metallic ("Metallic", Range(0, 1)) = 0

        [Header(Water Normal)]
        [Space(5)]
        _NormalStrength ("Scale", Float) = 1.0
        _MainNormal ("Main Normal", 2D) = "bump" { }
        _SecondNormal ("Second Normal", 2D) = "bump" { }

        [Header(Water)]
        _WaterSpeed ("Water Speed", Float) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma shader_feature_local _NORMALMAP

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            //#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
                float2 staticLightmapUV : TEXCOORD1;
            };

            struct Varyings {
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 viewDirectionWS : TEXCOORD2;
                half4 tangentWS : TEXCOORD3;
                float4 positionCS : SV_POSITION;
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 4);
            };
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_TexelSize;
            float4 _BaseMap_MipInfo;
            TEXTURE2D(_MainNormal);
            SAMPLER(sampler_MainNormal);
            TEXTURE2D(_SecondNormal);
            SAMPLER(sampler_SecondNormal);
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _MainNormal_ST;
            float4 _SecondNormal_ST;
            half4 _BaseColor;
            half _NormalStrength;
            float _Smoothness;
            float _Metallic;
            float _WaterSpeed;
            CBUFFER_END

            Varyings Vertex(Attributes input) {
                Varyings output;
                
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.viewDirectionWS = normalize(_WorldSpaceCameraPos - TransformObjectToWorld(input.positionOS.xyz));

                real3 tangentWS = real3(TransformObjectToWorldDir(input.tangentOS.xyz));
                real sign = input.tangentOS.w * (unity_WorldTransformParams.w >= 0.0 ? 1.0 : - 1.0);
                output.tangentWS = half4(tangentWS.xyz, sign);

                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

                OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                return output;
            }

            half3 SampleNormal(float2 uv, TEXTURE2D_PARAM(bumpMap, sampler_MainNormal), half scale = half(1.0)) {
                half4 n = SAMPLE_TEXTURE2D(bumpMap, sampler_MainNormal, uv);
                #if BUMP_SCALE_NOT_SUPPORTED
                    return UnpackNormal(n);
                #else
                    return UnpackNormalScale(n, scale);
                #endif
            }

            half4 SampleAlbedoAlpha(float2 uv, TEXTURE2D_PARAM(albedoAlphaMap, sampler_albedoAlphaMap)) {
                return half4(SAMPLE_TEXTURE2D(albedoAlphaMap, sampler_albedoAlphaMap, uv));
            }

            float3 NormalStrength(float3 In, float Strength) {
                return float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
            }

            half4 WaterNormalTS(float2 uv) {
                float speed = _WaterSpeed / 100;
                float uv1Speed = _Time.y * - 2 * speed;
                float2 uv1 = uv * _MainNormal_ST.xy + float2(uv1Speed, uv1Speed);
                float uv2Speed = _Time.y * speed;
                float2 uv2 = uv * _SecondNormal_ST.xy + float2(uv2Speed, uv2Speed);
                float3 normal1 = SampleNormal(uv1, TEXTURE2D_ARGS(_MainNormal, sampler_MainNormal));
                float3 normal2 = SampleNormal(uv2, TEXTURE2D_ARGS(_SecondNormal, sampler_SecondNormal));
                float3 normal = normal1 + normal2;
                normal = NormalStrength(normal, _NormalStrength);
                return half4(normal, 1);
            }

            void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData) {
                inputData = (InputData)0;

                float sgn = input.tangentWS.w;
                float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
                inputData.normalWS = TransformTangentToWorld(normalTS, tangentToWorld);

                inputData.viewDirectionWS = input.viewDirectionWS;
                inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, input.normalWS);
            }

            void InitializeSurfaceData(float2 uv, out SurfaceData surfaceData) {
                surfaceData = (SurfaceData)0;
                half4 albedo = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                surfaceData.albedo = albedo.rgb * _BaseColor.rgb;
                surfaceData.metallic = _Metallic;
                surfaceData.smoothness = _Smoothness;
                surfaceData.occlusion = 1;
                surfaceData.alpha = albedo.a * _BaseColor.a;
                surfaceData.normalTS =
                WaterNormalTS(uv);
                //SampleNormal(uv, TEXTURE2D_ARGS(_MainNormal, sampler_MainNormal), _NormalStrength);

            }

            half4 Fragment(Varyings input) : SV_Target {
                SurfaceData surfaceData;
                InitializeSurfaceData(input.uv, surfaceData);

                InputData inputData;
                InitializeInputData(input, surfaceData.normalTS, inputData);

                return UniversalFragmentPBR(inputData, surfaceData);
            }
            ENDHLSL
        }
    }
}