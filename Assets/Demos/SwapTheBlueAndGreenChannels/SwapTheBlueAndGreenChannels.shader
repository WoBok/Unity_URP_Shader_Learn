Shader "URP Shader/SwapTheBlueAndGreenChannels" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)

        [Header(PBR)]
        [Space(5)]
        _Smoothness ("Smoothness", Range(0, 1)) = 0
        _Metallic ("Metallic", Range(0, 1)) = 0

        _Noise ("Noise", 2D) = "white" { }
        _Noise_ST1 ("Noise ST1", Vector) = (1, 1, 1, 1)
        _Noise_ST2 ("Noise ST2", Vector) = (1, 1, 1, 1)
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
                float2 staticLightmapUV : TEXCOORD1;
            };

            struct Varyings {
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float4 positionCS : SV_POSITION;
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 3);
            };
            
            sampler2D _BaseMap;
            sampler2D _Noise;
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _Noise_ST;
            float4 _Noise_ST1;
            float4 _Noise_ST2;
            half4 _BaseColor;
            float _Smoothness;
            float _Metallic;
            CBUFFER_END

            Varyings Vertex(Attributes input) {
                Varyings output;
                
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);

                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

                OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                return output;
            }

            void InitializeInputData(Varyings input, out InputData inputData) {
                inputData = (InputData)0;
                inputData.normalWS = normalize(input.normalWS);
                inputData.viewDirectionWS = normalize(_WorldSpaceCameraPos - TransformObjectToWorld(input.positionWS.xyz));
                inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, input.normalWS);
            }

            void InitializeSurfaceData(float2 uv, out SurfaceData surfaceData) {
                surfaceData = (SurfaceData)0;
                half4 albedo = tex2D(_BaseMap, uv);
                surfaceData.albedo = albedo.rgb * _BaseColor.rgb;
                surfaceData.metallic = _Metallic;
                surfaceData.smoothness = _Smoothness;
                surfaceData.occlusion = 1;
                surfaceData.alpha = albedo.a * _BaseColor.a;
            }

            half4 Fragment(Varyings input) : SV_Target {
                InputData inputData;
                InitializeInputData(input, inputData);

                SurfaceData surfaceData;
                InitializeSurfaceData(input.uv, surfaceData);

                half4 color = UniversalFragmentPBR(inputData, surfaceData);

                half4 tempColor = color;

                half temp = color.g;
                color.g = color.b;
                color.b = temp;

                half4 noise = tex2D(_BaseMap, input.uv * _Noise_ST1.xy + _Noise_ST1.zw * _Time.x);
                color = lerp(tempColor, color, noise);

                temp = tempColor.r;
                tempColor.r = tempColor.g;
                tempColor.g = temp;

                noise = tex2D(_BaseMap, input.uv * _Noise_ST2.xy + _Noise_ST2.zw * _Time.x);
                color = lerp(color, tempColor, noise);

                return color;
            }
            ENDHLSL
        }
    }
}