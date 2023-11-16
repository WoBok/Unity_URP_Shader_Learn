Shader "URP Shader/HorizonOutline" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
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
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD2;
                half4 color : COLOR;
            };
            
            sampler2D _BaseMap;
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;

                float3 positionWS = TransformObjectToWorld(input.positionOS);
                float3 normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));

                float y = positionWS.y;
                float s = step(-0.01, y) * step(y, 0.01);
                positionWS.xz += normalize(normalWS.xz) * s * 0.1;

                output.positionCS = TransformWorldToHClip(positionWS);
                
                output.positionWS = positionWS;
                output.normalWS = normalWS;

                output.uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;


                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                half4 albedo = tex2D(_BaseMap, input.uv);

                half4 diffuse = albedo * (dot(input.normalWS, normalize(_MainLightPosition.xyz)) * 0.5 + 0.5);

                float y = input. positionWS.y;

                float s = step(-0.01, y) * step(y, 0.01);

                half4 color = half4(s, 0, 0, 1);

                return diffuse * _BaseColor * color;
            }
            ENDHLSL
        }
    }
}