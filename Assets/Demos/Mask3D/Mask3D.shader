Shader "URP Shader/Mask3D" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        [HDR] _Emission ("Emission", Color) = (0, 0, 0, 0)
        _Smoothness ("Smoothness", Range(0, 1)) = 0
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Occlusion ("Occlusion", Range(0, 1)) = 1
    }

    SubShader {

        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {

            Tags { "LightMode" = "UniversalForward" }

            //ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            ZTest Off
            HLSLPROGRAM

            #pragma target 4.5

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_ON

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
                float alpha : TEXCOORD5;
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);

                float4 positionCS : SV_POSITION;
            };
            
            sampler2D _BaseMap;
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            half4 _Emission;
            float _Smoothness, _Metallic, _Occlusion;
            CBUFFER_END

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
                output.alpha = 0;


                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                half4 albedo = tex2D(_BaseMap, input.uv);

                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.albedo = albedo * _BaseColor;
                surfaceData.metallic = _Metallic;
                surfaceData.smoothness = _Smoothness;
                surfaceData.emission = _Emission;
                surfaceData.occlusion = _Occlusion;

                InputData inputData;
                InitializeInputData(input, inputData);

                half4 color = UniversalFragmentPBR(inputData, surfaceData);
                //color.a = input.alpha;
                float alpha = 0;
                if ((input.positionWS.x < 1 && input.positionWS.x > - 1) && (input.positionWS.z < 1 && input.positionWS.z > - 1)) {
                    alpha = 1;
                }
                return color * alpha;
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}