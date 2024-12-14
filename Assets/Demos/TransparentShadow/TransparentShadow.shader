Shader "URP Shader/TransparentShadow" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Geometry+1" }
        //Blend SrcAlpha OneMinusSrcAlpha

        Pass {
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings {
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float4 positionCS : SV_POSITION;
                float4 shadowCoord : TEXCOORD6;
            };
            
            sampler2D _BaseMap;
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);
                
                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));

                output.uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;

                float3 positionWS = TransformObjectToWorld(input.positionOS);

                output.shadowCoord = TransformWorldToShadowCoord(positionWS);

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {
                Light mainLight = GetMainLight(input.shadowCoord);
                half shadowAttenuation = mainLight.shadowAttenuation;
                half shadow = MainLightRealtimeShadow(input.shadowCoord);
                //half4 color = half4(_BaseColor.rgb, saturate(1 - shadowAttenuation) * _BaseColor.a);
                half4 color = half4(shadow, shadow, shadow, 1);
                return color;
            }
            ENDHLSL
        }
    }
}