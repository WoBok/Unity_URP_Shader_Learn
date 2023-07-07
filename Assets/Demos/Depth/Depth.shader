Shader "Demo/Depth/Depth" {
    Properties {
        _Scale ("Scale", int) = 10
    }
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
            };

            struct Varyings {
                float4 positionCS : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
            int _Scale;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                float2 UV = input.positionCS.xy / _ScaledScreenParams.xy;

                #if UNITY_REVERSED_Z
                    real depth = SampleSceneDepth(UV);
                #else
                    real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(UV));
                #endif

                float3 worldPos = ComputeWorldSpacePosition(UV, depth, UNITY_MATRIX_I_VP);

                uint3 worldIntPos = uint3(abs(worldPos.xyz * _Scale));
                bool white = (worldIntPos.x & 1)^(worldIntPos.y & 1)^(worldIntPos.z & 1);
                half4 color = white ?       half4(1, 1, 1, 1) : half4(0, 0, 0, 1);

                #if UNITY_REVERSED_Z
                    if (depth < 0.0001)
                        return half4(0, 0, 0, 1);
                #else
                    if (depth > 0.9999)
                        return half4(0, 0, 0, 1);
                #endif

                return color;
            }
            ENDHLSL
        }
    }
}