Shader "URP Shader/GPU Instancing" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            HLSLPROGRAM

            #pragma multi_compile_instancing
            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings {
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float4 positionCS : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            sampler2D _BaseMap;
            float4 _BaseMap_ST;

            UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
            UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
            UNITY_DEFINE_INSTANCED_PROP(float, _PositionDelta)
            UNITY_DEFINE_INSTANCED_PROP(float, _Speed)
            UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float positionDelta = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _PositionDelta);
                float speed = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Speed);
                input.positionOS.x += sin(_Time.x * speed + positionDelta);
                input.positionOS.y += sin(_Time.y * speed + positionDelta);
                input.positionOS.z += sin(_Time.z * speed + positionDelta);

                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);
                
                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));

                output.uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {
                UNITY_SETUP_INSTANCE_ID(input);

                half4 albedo = tex2D(_BaseMap, input.uv);

                half4 diffuse = albedo * (dot(input.normalWS, normalize(_MainLightPosition.xyz)) * 0.5 + 0.5);

                half4 color = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);

                return diffuse * color;
            }
            ENDHLSL
        }
    }
}