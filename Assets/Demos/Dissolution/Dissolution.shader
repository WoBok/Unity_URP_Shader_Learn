Shader "URP Shader/Dissolution" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)

        [Header(PBR)]
        [Space(5)]
        _Smoothness ("Smoothness", Range(0, 1)) = 0
        _Metallic ("Metallic", Range(0, 1)) = 0

        [Header(Dissolution)]
        [Space(5)]
        _Density ("Density", Float) = 10
        _Range ("Range", Range(0, 1)) = 0
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

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
                float3 viewDirectionWS : TEXCOORD2;
                float4 positionCS : SV_POSITION;
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 3);
            };
            
            sampler2D _BaseMap;
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            float _Smoothness;
            float _Metallic;
            float _Density;
            float _Range;
            CBUFFER_END

            Varyings Vertex(Attributes input) {
                Varyings output;
                
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.viewDirectionWS = normalize(_WorldSpaceCameraPos - TransformObjectToWorld(input.positionOS.xyz));

                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

                OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                return output;
            }

            float2 hash22(float2 p) {
                p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
            }

            float perlin_noise(float2 p) {
                float2 pi = floor(p);
                float2 pf = p - pi;
                float2 w = pf * pf * (3.0 - 2.0 * pf);
                return lerp(lerp(dot(hash22(pi + float2(0.0, 0.0)), pf - float2(0.0, 0.0)),
                dot(hash22(pi + float2(1.0, 0.0)), pf - float2(1.0, 0.0)), w.x),
                lerp(dot(hash22(pi + float2(0.0, 1.0)), pf - float2(0.0, 1.0)),
                dot(hash22(pi + float2(1.0, 1.0)), pf - float2(1.0, 1.0)), w.x), w.y);
            }

            void InitializeInputData(Varyings input, out InputData inputData) {
                inputData = (InputData)0;
                inputData.normalWS = normalize(input.normalWS);
                inputData.viewDirectionWS = input.viewDirectionWS;
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

                float noise = perlin_noise(uv * _Density);
                float t = saturate((noise + 1) * (1 / (_Range * 1.7)));
                surfaceData.alpha = step(1, t);
            }

            half4 Fragment(Varyings input) : SV_Target {
                InputData inputData;
                InitializeInputData(input, inputData);

                SurfaceData surfaceData;
                InitializeSurfaceData(input.uv, surfaceData);

                return UniversalFragmentPBR(inputData, surfaceData);
            }
            ENDHLSL
        }
    }
}