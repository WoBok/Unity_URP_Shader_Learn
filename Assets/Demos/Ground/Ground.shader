Shader "URP Shader/Ground" {
    Properties {
        [HideInInspector]_BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        [HDR] _Emission ("Emission", Color) = (0, 0, 0, 0)
        _Smoothness ("Smoothness", Range(0, 1)) = 0
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Occlusion ("Occlusion", Range(0, 1)) = 1

        _Albedo1 ("Albedo1", 2D) = "white" { }
        _Color0 ("Color 0", Color) = (0, 0, 0, 0)
        _Albedo2 ("Albedo2", 2D) = "white" { }
        _Albedo3 ("Albedo3", 2D) = "white" { }
        _Metallic1 ("Metallic1", 2D) = "white" { }
        _Metallic2 ("Metallic2", 2D) = "white" { }
        _Metallic3 ("Metallic3", 2D) = "white" { }
        _Normal1 ("Normal1", 2D) = "bump" { }
        _Normal2 ("Normal2", 2D) = "bump" { }
        _Normal3 ("Normal3", 2D) = "bump" { }
        _COLOR ("COLOR", 2D) = "white" { }
        _Float0 ("Float 0", Range(0, 4)) = 1
        _Normal_Global ("Normal_Global", 2D) = "bump" { }
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

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);

                float4 positionCS : SV_POSITION;
            };
            
            sampler2D _BaseMap;
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            half4 _Emission;
            float _Smoothness, _Metallic, _Occlusion;

            uniform float _Float0;
            uniform sampler2D _Normal1;
            uniform float4 _Normal1_ST;
            uniform sampler2D _Normal2;
            uniform float4 _Normal2_ST;
            uniform sampler2D _COLOR;
            uniform float4 _COLOR_ST;
            uniform sampler2D _Normal3;
            uniform float4 _Normal3_ST;
            uniform sampler2D _Normal_Global;
            uniform float4 _Normal_Global_ST;
            uniform sampler2D _Albedo1;
            uniform float4 _Albedo1_ST;
            uniform float4 _Color0;
            uniform sampler2D _Albedo2;
            uniform float4 _Albedo2_ST;
            uniform sampler2D _Albedo3;
            uniform float4 _Albedo3_ST;
            uniform sampler2D _Metallic1;
            uniform float4 _Metallic1_ST;
            uniform sampler2D _Metallic2;
            uniform float4 _Metallic2_ST;
            uniform sampler2D _Metallic3;
            uniform float4 _Metallic3_ST;
            CBUFFER_END

            half3 UnpackScaleNormalRGorAG(half4 packednormal, half bumpScale) {
                #if defined(UNITY_NO_DXT5nm)
                    half3 normal = packednormal.xyz * 2 - 1;
                    #if (SHADER_TARGET >= 30)
                        normal.xy *= bumpScale;
                    #endif
                    return normal;
                #elif defined(UNITY_ASTC_NORMALMAP_ENCODING)
                    half3 normal;
                    normal.xy = (packednormal.wy * 2 - 1);
                    normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
                    normal.xy *= bumpScale;
                    return normal;
                #else
                    // This do the trick
                    packednormal.x *= packednormal.w;

                    half3 normal;
                    normal.xy = (packednormal.xy * 2 - 1);
                    #if (SHADER_TARGET >= 30)
                        normal.xy *= bumpScale;
                    #endif
                    normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
                    return normal;
                #endif
            }

            half3 UnpackScaleNormal(half4 packednormal, half bumpScale) {
                return UnpackScaleNormalRGorAG(packednormal, bumpScale);
            }

            half3 BlendNormals(half3 n1, half3 n2) {
                return normalize(half3(n1.xy + n2.xy, n1.z * n2.z));
            }

            void InitializeInputData(Varyings input, out InputData inputData) {
                half3 viewDirWS = _WorldSpaceCameraPos - input.positionWS;
                inputData = (InputData)0;
                inputData.positionWS = input.positionWS;
                inputData.viewDirectionWS = normalize(viewDirWS);
                inputData.normalWS = normalize(input.normalWS);
                inputData.shadowCoord = input.shadowCoord;
                inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
                inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);
            }

            Varyings Vertex(Attributes input) {

                Varyings output = (Varyings)0;
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.normalWS = normalInput.normalWS;
                output.positionWS = vertexInput.positionWS;
                output.shadowCoord = GetShadowCoord(vertexInput);
                output.positionCS = vertexInput.positionCS;
                OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {
                float2 uv_Normal1 = input.uv * _Normal1_ST.xy + _Normal1_ST.zw;
                float2 uv_Normal2 = input.uv * _Normal2_ST.xy + _Normal2_ST.zw;
                float2 uv_COLOR = input.uv * _COLOR_ST.xy + _COLOR_ST.zw;
                float4 tex2DNode13 = tex2D(_COLOR, uv_COLOR);
                float2 uv_Normal3 = input.uv * _Normal3_ST.xy + _Normal3_ST.zw;
                float2 uv_Normal_Global = input.uv * _Normal_Global_ST.xy + _Normal_Global_ST.zw;
                float3 Normal = BlendNormals(lerp(lerp(UnpackScaleNormal(tex2D(_Normal1, uv_Normal1), _Float0), UnpackScaleNormal(tex2D(_Normal2, uv_Normal2), _Float0), tex2DNode13.r), UnpackScaleNormal(tex2D(_Normal3, uv_Normal3), _Float0), tex2DNode13.g), UnpackNormal(tex2D(_Normal_Global, uv_Normal_Global)));
                float2 uv_Albedo1 = input.uv * _Albedo1_ST.xy + _Albedo1_ST.zw;
                float2 uv_Albedo2 = input.uv * _Albedo2_ST.xy + _Albedo2_ST.zw;
                float2 uv_Albedo3 = input.uv * _Albedo3_ST.xy + _Albedo3_ST.zw;
                float2 uv_Metallic1 = input.uv * _Metallic1_ST.xy + _Metallic1_ST.zw;
                float4 tex2DNode21 = tex2D(_Metallic1, uv_Metallic1);
                float2 uv_Metallic2 = input.uv * _Metallic2_ST.xy + _Metallic2_ST.zw;
                float4 tex2DNode22 = tex2D(_Metallic2, uv_Metallic2);
                float2 uv_Metallic3 = input.uv * _Metallic3_ST.xy + _Metallic3_ST.zw;
                float4 tex2DNode24 = tex2D(_Metallic3, uv_Metallic3);
                half3 Albedo = lerp(lerp(tex2D(_Albedo1, uv_Albedo1), (_Color0 * tex2D(_Albedo2, uv_Albedo2)), tex2DNode13.r), tex2D(_Albedo3, uv_Albedo3), tex2DNode13.g).rgb;
                half Metallic = lerp(lerp(tex2DNode21, tex2DNode22, tex2DNode13.r), tex2DNode24, tex2DNode13.g).r;
                half Smoothness = lerp(lerp(tex2DNode21.a, tex2DNode22.a, tex2DNode13.r), tex2DNode24.a, tex2DNode13.g);

                InputData inputData;
                InitializeInputData(input, inputData);

                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.albedo = Albedo * _BaseColor;
                surfaceData.normalTS = Normal;
                surfaceData.metallic = Metallic;
                surfaceData.smoothness = Smoothness;
                surfaceData.emission = _Emission;
                surfaceData.occlusion = _Occlusion;
                surfaceData.alpha = 1;

                half4 color = UniversalFragmentPBR(inputData, surfaceData);

                return color;
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}