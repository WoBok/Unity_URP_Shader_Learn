Shader "LiQingZhao/Outline" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _OutlineWidth ("Outline Width", float) = 0.1
        _DiffuseFrontIntensity ("Front Light Intensity", float) = 1
        _DiffuseBackIntensity ("Back Light Intensity", float) = 0.5
        [Toggle]ReceiveShadow ("Receive Shadow", int) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma multi_compile _ LIGHTMAP_ON

            #pragma shader_feature RECEIVESHADOW_ON

            #pragma multi_compile  _MAIN_LIGHT_SHADOWS
            #pragma multi_compile  _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile  _SHADOWS_SOFT

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
                float2 uv : TEXCOORD0;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
                float3 normalWS : TEXCOORD2;
                float3 viewDirWS : TEXCOORD3;
                float4 shadowCoord : TEXCOORD4;
            };
            
            sampler2D _BaseMap;
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            float _OutlineWidth;
            float _DiffuseFrontIntensity;
            float _DiffuseBackIntensity;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                
                output. viewDirWS = normalize(_WorldSpaceCameraPos.xyz - positionWS);
                
                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));

                output.uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;

                output.shadowCoord = TransformWorldToShadowCoord(positionWS);

                OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                half4 color;

                half4 albedo = tex2D(_BaseMap, input.uv);

                float3 worldLightDir = normalize(_MainLightPosition.xyz);
                float halfLambert = dot(input.normalWS, worldLightDir) * 0.5 + 0.5;
                half3 diffuse = _MainLightColor.rgb * albedo.rgb * halfLambert * _DiffuseFrontIntensity;
                float oneMinusHalfLambert = 1 - halfLambert;
                diffuse += _MainLightColor.rgb * albedo.rgb * oneMinusHalfLambert * _DiffuseBackIntensity;

                diffuse *= SAMPLE_GI(input.lightmapUV, input.vertexSH, input.normalWS);

                float factor = dot(normalize(input.normalWS), normalize(input.viewDirWS));
                factor = step(_OutlineWidth, factor);

                color = half4(diffuse, 1) * _BaseColor * factor ;

                #if defined(RECEIVESHADOW_ON)
                    Light mainLight = GetMainLight(input.shadowCoord);
                    half3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
                    half3 lightDiffuseColor = LightingLambert(attenuatedLightColor, mainLight.direction, input.normalWS);
                    color.rgb *= lightDiffuseColor + _GlossyEnvironmentColor.rgb;
                #endif

                return color;
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}