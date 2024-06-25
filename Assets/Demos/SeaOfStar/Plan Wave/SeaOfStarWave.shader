Shader "URP Shader/SeaOfStarWave" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        [HDR]_BaseColor ("Color", Color) = (1, 1, 1, 1)
        [Header(Wave)]
        [Space(5)]
        _WaveSpeed ("Wave Speed", Float) = 1
        _Wave1 ("Wave 1 Wavelength, Steepness, Direction", Vector) = (10, 0.5, 1, 0)
        _Wave2 ("Wave 2 Wavelength, Steepness, Direction", Vector) = (20, 0.25, 0, 1)
        _Wave3 ("Wave 3 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave4 ("Wave 4 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave5 ("Wave 5 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave6 ("Wave 6 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave7 ("Wave 7 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave8 ("Wave 8 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave9 ("Wave 9 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave10 ("Wave 10 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave11 ("Wave 11 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave12 ("Wave 12 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Pass {
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "GerstnerWave.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings {
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float4 positionCS : SV_POSITION;
            };
            
            sampler2D _BaseMap;
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;

                float3 tangent = float3(1, 0, 0);
                float3 binormal = float3(0, 0, 1);
                float3 position = input.positionOS.xyz;

                GERSTNER_WAVE(_Wave1) GERSTNER_WAVE(_Wave2) GERSTNER_WAVE(_Wave3) GERSTNER_WAVE(_Wave4)
                GERSTNER_WAVE(_Wave5) GERSTNER_WAVE(_Wave6)GERSTNER_WAVE(_Wave7) GERSTNER_WAVE(_Wave8)
                GERSTNER_WAVE(_Wave9) GERSTNER_WAVE(_Wave10) GERSTNER_WAVE(_Wave11) GERSTNER_WAVE(_Wave12)

                float3 normal = normalize(cross(binormal, tangent));
                
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);
                
                output.normalWS = normalize(mul(normal, (float3x3)unity_WorldToObject));

                output.uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                half4 albedo = tex2D(_BaseMap, input.uv);

                half4 diffuse = albedo * (dot(input.normalWS, normalize(_MainLightPosition.xyz)) * 0.5 + 0.5);

                return diffuse * _BaseColor;
            }
            ENDHLSL
        }
    }
}