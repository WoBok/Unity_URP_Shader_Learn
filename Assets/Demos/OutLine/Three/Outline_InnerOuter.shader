Shader "LiQingZhao/Outline_InnerOuter" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)

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
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma shader_feature RECEIVESHADOW_ON
            #pragma shader_feature ALPHACLIPPING_ON
            #pragma shader_feature OUTLINESWITCH_ON
            #pragma shader_feature INNERLINESWITCH_ON
            #if defined(RECEIVESHADOW_ON)
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #endif

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
                float4 shadowCoord : TEXCOORD4;
                float2 uv[9] : TEXCOORD5;
            };
            
            sampler2D _BaseMap;
            CBUFFER_START(UnityPerMaterial)
            half4 _BaseMap_TexelSize;
            half4 _BaseColor;
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

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                
                output. viewDirWS = normalize(_WorldSpaceCameraPos.xyz - positionWS);
                
                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));

                OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                output.shadowCoord = TransformWorldToShadowCoord(positionWS);

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

                float3 worldLightDir = normalize(float3(0.1, 0.3, 0.2));
                float halfLambert = dot(input.normalWS, worldLightDir) * 0.5 + 0.5;
                half3 diffuse = albedo.rgb * halfLambert * _DiffuseFrontIntensity;//_MainLightColor.rgb *
                float oneMinusHalfLambert = 1 - halfLambert;
                diffuse += _MainLightColor.rgb * albedo.rgb * oneMinusHalfLambert * _DiffuseBackIntensity;

                diffuse *= SAMPLE_GI(input.lightmapUV, input.vertexSH, input.normalWS);

                color = half4(diffuse, 1) * _BaseColor;

                #if defined(RECEIVESHADOW_ON)
                    Light mainLight = GetMainLight(input.shadowCoord);
                    color *= mainLight.shadowAttenuation;
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

                return color;
            }
            ENDHLSL
        }
        
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}