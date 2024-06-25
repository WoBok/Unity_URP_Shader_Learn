Shader "URP Shader/SeaOfStar" {
    Properties {
        [HDR]_BaseColor ("Color", Color) = (1, 1, 1, 1)
        _BlurRange ("Blur Rnage", Range(0, 1)) = 0.3
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" }

        Blend SrcAlpha OneMinusSrcAlpha

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
            
            half4 _BaseColor;
            float _BlurRange;

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                float3 forward = normalize(TransformWorldToObject(_WorldSpaceCameraPos));
                half isVertical = step(0.999, forward.y);
                float3 up = isVertical * float3(0, 0, 1) + (1 - isVertical) * float3(0, 1, 0);
                float3 right = normalize(cross(forward, up));
                up = normalize(cross(right, forward));

                float3 newPos = input.positionOS.x * right + input.positionOS.y * up + input.positionOS.z * forward;
                
                output.positionCS = mul(UNITY_MATRIX_MVP, float4(newPos, input.positionOS.w));
                
                output.uv = input.texcoord;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {
                float2 uv = input.uv * 2 - 1;
                float d = sqrt(pow(uv.x, 2) + pow(uv.y, 2));
                //d = 1 - pow((saturate(d) - 1), 8);
                d = sqrt(1 - pow((saturate(d) - 1), 2));
                //思路：分两段做，范围内的较为实，范围外的虚
                float alpha = smoothstep(1, 1 - _BlurRange, d);
                _BaseColor.a = alpha;

                return _BaseColor;
            }
            ENDHLSL
        }
    }
}