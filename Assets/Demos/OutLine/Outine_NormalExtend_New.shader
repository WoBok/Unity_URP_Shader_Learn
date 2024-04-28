Shader "URP Shader/Outine NormalExtend New" {
    Properties {
        _OutlineColor ("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineScale("Outline Scale",float)=1
        _OutlineWidth("Outline Width",float)=0.1
        _OutlineDepthOffset("Outline Depth Offset",float)=0
        _CameraDistanceImpact("Camera Distance Impact",Range(0,1))=0.5
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            Name "Outline"
            Tags { "LightMode" = "SRPDefaultUnlit" }

            Cull Front

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram

            #pragma multi_compile _ DR_OUTLINE_ON
            #pragma multi_compile_fog

            struct VertexInput {
                float4 position : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput {
                float4 position : SV_POSITION;
                float3 normal : NORMAL;

                float fogCoord : TEXCOORD1;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
            half4 _OutlineColor;
            float _OutlineScale;
            float _OutlineWidth;
            float _OutlineDepthOffset;
            float _CameraDistanceImpact;
            CBUFFER_END

            float4 ObjectToClipPos(float4 pos) {
                return mul(UNITY_MATRIX_VP, mul(UNITY_MATRIX_M, float4(pos.xyz, 1)));
            }

            VertexOutput VertexProgram(VertexInput v) {
                VertexOutput o;

                UNITY_SETUP_INSTANCE_ID(v);

                o = (VertexOutput)0;
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                    float4 clipPosition = ObjectToClipPos(v.position * _OutlineScale);
                    const float3 clipNormal = mul((float3x3)UNITY_MATRIX_VP, mul((float3x3)UNITY_MATRIX_M, v.normal));
                    const half outlineWidth = _OutlineWidth;
                    const half cameraDistanceImpact = lerp(clipPosition.w, 4.0, _CameraDistanceImpact);
                    const float2 aspectRatio = float2(_ScreenParams.x / _ScreenParams.y, 1);
                    const float2 offset = normalize(clipNormal.xy) / aspectRatio * outlineWidth * cameraDistanceImpact * 0.005;
                    clipPosition.xy += offset;
                    const half outlineDepthOffset = _OutlineDepthOffset;

                    #if UNITY_REVERSED_Z
                        clipPosition.z -= outlineDepthOffset * 0.1;
                    #else
                        clipPosition.z += outlineDepthOffset * 0.1 * (1.0 - UNITY_NEAR_CLIP_VALUE);
                    #endif

                    o.position = clipPosition;
                    o.normal = clipNormal;

                    o.fogCoord = ComputeFogFactor(o.position.z);

                return o;
            }

            half4 FragmentProgram(VertexOutput i) : SV_TARGET {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                half4 color = _OutlineColor;
                color.rgb = MixFog(color.rgb, i.fogCoord);
                return color;
            }
            ENDHLSL
        }
    }
}