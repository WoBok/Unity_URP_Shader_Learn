Shader "URP Shader/Billboarding" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
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
                float4 positionCS : SV_POSITION;
            };
            
            sampler2D _BaseMap;
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                float3 forward = normalize(TransformWorldToObject(_WorldSpaceCameraPos));
                half isVertical = step(0.999, forward.y);
                float3 up = isVertical * float3(0, 0, 1) + (1 - isVertical) * float3(0, 1, 0);
                float3 right = normalize(cross(up, forward));
                up = normalize(cross(forward, right));

                float3 newPos = input.positionOS.x * right + input.positionOS.y * up + input.positionOS.z * forward;

                output.positionCS = mul(UNITY_MATRIX_MVP, float4(newPos, input.positionOS.w));
                
                output.uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                half4 albedo = tex2D(_BaseMap, input.uv);

                return albedo * _BaseColor;
            }
            ENDHLSL
        }
    }
}