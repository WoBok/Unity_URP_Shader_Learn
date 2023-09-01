Shader "URP Shader/OutLine" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _Power ("Power", float) = 1
        _Edge ("Edge", float) = 2
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 viewDirWS : TEXCOORD2;
            };
            
            sampler2D _BaseMap;
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            float _Power;
            float _Edge;
            CBUFFER_END

            //float GetFactor(float3 normalWS, float3 viewDirWS, float Power) {
            //    return pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
            //}

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                output. viewDirWS = normalize(_WorldSpaceCameraPos.xyz - TransformObjectToWorld(input.positionOS.xyz));
                
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);
                
                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));

                output.uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;


                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                half4 albedo = tex2D(_BaseMap, input.uv);

                half4 diffuse = albedo * (dot(input.normalWS, normalize(_MainLightPosition.xyz)) * 0.5 + 0.5);

                float f = pow((1.0 - saturate(dot(normalize(input.normalWS), normalize(input.viewDirWS)))), _Power);
                f = 1 - f;
                f = step(_Edge, f);
                f = 1 - f;
                float o = min(2 * (2 - 0.5), 1);
                f = lerp(0, o, f);


                return (1-f) * albedo * _BaseColor;
            }
            ENDHLSL
        }
    }
}