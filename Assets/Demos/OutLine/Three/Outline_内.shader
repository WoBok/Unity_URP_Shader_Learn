Shader "LiQingZhao/Outline_InnerOuter" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)

        [Header(Emission)]
        [Toggle]EmissionSwitch ("Emission Switch", int) = 0
        _EmissionMap ("Emission Map", 2D) = "white" { }
        [HDR]_Emission ("Emission", Color) = (0, 0, 0, 0)

        [Header(Light)]
        _DiffuseFrontIntensity ("Front Light Intensity", float) = 1
        _DiffuseBackIntensity ("Back Light Intensity", float) = 0.5
        [Toggle]ReceiveShadow ("Receive Shadow", int) = 1

        [Header(Outline)]
        [Toggle]OutlineSwitch ("Outline Switch", int) = 1
        _OutlineWidth ("Outline Width", float) = 0.1
        [Toggle]InnerLineSwitch ("Inner Line Switch", int) = 0
        _InnerLineColor ("Inner Line Color", Color) = (0, 0, 0, 0)
        _InnerLineThreshold ("Inner Line Threshold", Range(0, 1)) = 0
        _Denoise ("Denoise", float) = 0

        [Header(Alpha)]
        [Toggle]AlphaClipping ("Alpah Clipping", int) = 0
        _AlphaClipThreshold ("Threshold", Range(0, 1)) = 0.5

        [Toggle]ReceiveShadow ("Receive Shadow", int) = 1

        [Enum(UnityEngine.Rendering.CullMode)]_Cull ("Cull", float) = 2
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {

            Cull[_Cull]

            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma shader_feature EMISSIONSWITCH_ON
            #pragma shader_feature ALPHACLIPPING_ON
            #pragma shader_feature OUTLINESWITCH_ON
            #pragma shader_feature INNERLINESWITCH_ON

            #pragma shader_feature RECEIVESHADOW_ON

            #pragma multi_compile  _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile  _SHADOWS_SOFT
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS

            #pragma multi_compile _ SHADOWS_SHADOWMASK

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
                float2 lightmapUV : TEXCOORD1;
            };

            struct Varyings {
                float4 positionCS : SV_POSITION;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
                float3 normalWS : TEXCOORD2;
                float3 viewDirWS : TEXCOORD3;
                half3 additionalLight : TEXCOORD4;
                float3 positionWS : TEXCOORD5;
                float2 uv[9] : TEXCOORD6;
            };
            
            sampler2D _BaseMap;
            sampler2D _EmissionMap;
            CBUFFER_START(UnityPerMaterial)
            half4 _BaseMap_TexelSize;
            half4 _BaseColor;
            half4 _Emission;
            float _OutlineWidth;
            float _DiffuseFrontIntensity;
            float _DiffuseBackIntensity;
            half4 _InnerLineColor;
            half _InnerLineThreshold;
            half _Denoise;
            float _AlphaClipThreshold;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

                output.positionWS = positionWS;

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                
                output. viewDirWS = normalize(_WorldSpaceCameraPos.xyz - positionWS);
                
                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));

                OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                half2 uv = input.texcoord;
                output.uv[0] = uv + _BaseMap_TexelSize.xy * half2(-1, -1);
                output.uv[1] = uv + _BaseMap_TexelSize.xy * half2(0, -1);
                output.uv[2] = uv + _BaseMap_TexelSize.xy * half2(1, -1);
                output.uv[3] = uv + _BaseMap_TexelSize.xy * half2(-1, 0);
                output.uv[4] = uv + _BaseMap_TexelSize.xy * half2(0, 0);
                output.uv[5] = uv + _BaseMap_TexelSize.xy * half2(1, 0);
                output.uv[6] = uv + _BaseMap_TexelSize.xy * half2(-1, 1);
                output.uv[7] = uv + _BaseMap_TexelSize.xy * half2(0, 1);
                output.uv[8] = uv + _BaseMap_TexelSize.xy * half2(1, 1);

                #ifdef _ADDITIONAL_LIGHTS_VERTEX
                    half3 additionalLight = VertexLighting(positionWS, output.normalWS);
                    output.additionalLight = additionalLight;
                #endif

                return output;
            }

            half Lum(half4 color) {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            half Sobel(Varyings input) {

                const half Gx[9] = {
                    - 1, -2, -1,
                    0, 0, 0,
                    1, 2, 1
                };
                const half Gy[9] = {
                    - 1, 0, 1,
                    - 2, 0, 2,
                    - 1, 0, 1
                };

                half texLuminance;
                half edgeX = 0;
                half edgeY = 0;
                for (int i = 0; i < 9; i++) {
                    texLuminance = Lum(tex2D(_BaseMap, input.uv[i]));
                    edgeX += texLuminance * Gx[i];
                    edgeY += texLuminance * Gy[i];
                }

                half edgeXDenoise = step(edgeX, _Denoise);
                half edgeYDenoise = step(edgeY, _Denoise);
                half edge = 1 - abs(edgeX) * edgeXDenoise - abs(edgeY) * edgeYDenoise;

                return edge;
            }

            half4 Fragment(Varyings input) : SV_Target {

                half4 color;

                half4 albedo = tex2D(_BaseMap, input.uv[4]);

                float3 worldLightDir = normalize(_MainLightPosition.xyz);
                float halfLambert = dot(input.normalWS, worldLightDir) * 0.5 + 0.5;
                half3 diffuse = _MainLightColor.rgb * albedo.rgb * halfLambert * _DiffuseFrontIntensity;
                float oneMinusHalfLambert = 1 - halfLambert;
                diffuse += _MainLightColor.rgb * albedo.rgb * oneMinusHalfLambert * _DiffuseBackIntensity;

                #ifdef _ADDITIONAL_LIGHTS_VERTEX
                    diffuse += input.additionalLight;
                #endif

                half4 shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

                #if defined(_ADDITIONAL_LIGHTS)
                    uint pixelLightCount = GetAdditionalLightsCount();

                    LIGHT_LOOP_BEGIN(pixelLightCount)
                    Light light = GetAdditionalLight(lightIndex, input.positionWS, shadowMask);
                    #ifdef _LIGHT_LAYERS
                        uint meshRenderingLayers = GetMeshRenderingLayer();
                        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
                    #endif 
                    {
                    half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
                    half3 lightDiffuseColor = LightingLambert(attenuatedLightColor, light.direction, input.normalWS);
                    diffuse += lightDiffuseColor;
                }
                LIGHT_LOOP_END
                #endif

                diffuse *= SAMPLE_GI(input.lightmapUV, input.vertexSH, input.normalWS);

                color = half4(diffuse, 1) * _BaseColor;

                #if defined(RECEIVESHADOW_ON)
                    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                    Light mainLight = GetMainLight(shadowCoord, input.positionWS, shadowMask);
                    half3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
                    half3 lightDiffuseColor = LightingLambert(attenuatedLightColor, mainLight.direction, input.normalWS);
                    color.rgb *= lightDiffuseColor + _GlossyEnvironmentColor.rgb;
                #endif

                #if defined(OUTLINESWITCH_ON)
                    float factor = saturate(dot(normalize(input.normalWS), normalize(input.viewDirWS)));
                    factor = step(_OutlineWidth, factor);
                    color *= factor ;
                #endif

                #if defined(INNERLINESWITCH_ON)
                    half edge = Sobel(input);
                    edge = step(_InnerLineThreshold, edge);
                    color = lerp(_InnerLineColor, color, edge);
                #endif

                #if defined(ALPHACLIPPING_ON)
                    half alphaTest = albedo.a;
                    clip(alphaTest - _AlphaClipThreshold);
                    color.a *= alphaTest;
                #endif

                #if defined(EMISSIONSWITCH_ON)
                    half4 emissionColor = tex2D(_EmissionMap, input.uv[4]);
                    emissionColor *= _Emission;
                    color += emissionColor;
                #endif

                return color;
            }
            ENDHLSL
        }
        
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}