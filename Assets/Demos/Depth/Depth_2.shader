Shader "Demo/Depth/Depth_2" {
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
                float3 screenPos : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
            int _Scale;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);

                output.screenPos = ComputeScreenPos(output.positionCS);

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                //Fragment Shader的输入是在什么空间？
                //不是NDC，而是屏幕空间Screen Space。
                float2 UV = input.positionCS.xy / _ScaledScreenParams.xy;
                //float2 UV = input.screenPos.xy / input.screenPos.w;//同上相同效果

                //NDC中z分量范围在[-1,1]之间，通过映射：depth=0.5*Zndc+0.5，使其范围在[0,1]之间，存储到贴图中
                #if UNITY_REVERSED_Z
                    real depth = SampleSceneDepth(UV);
                #else
                    real depth = 1 - SampleSceneDepth(UV);
                #endif

                float eyeDepth = LinearEyeDepth(depth, _ZBufferParams);

                half4 color = half4(depth, depth, depth, 1);

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