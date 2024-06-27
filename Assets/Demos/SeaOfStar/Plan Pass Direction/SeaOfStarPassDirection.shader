Shader "URP Shader/SeaOfStarPassDirection" {
    Properties {
        [HDR]_BaseColor ("Color", Color) = (1, 1, 1, 1)
        _BlurRange ("Blur Rnage", Range(0, 1)) = 0.3
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" }

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off
        Pass {
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #pragma multi_compile_instancing
            #pragma instancing_options procedural:SetupMatrix

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            half4 _BaseColor;
            float _BlurRange;

            #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
                struct Star {
                    float3 position;
                    float3 direction;
                    float3 forward;
                    float movementSpeed;
                    float rotationSpeed;
                    float scale;
                };

                StructuredBuffer<Star> starts;//不可为RW

                float3 _Position ;
                float _Scale;
                float4x4 _ObjectToWorldMatrix;
            #endif

            void SetupMatrix() {
                #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
                    Star star = starts[unity_InstanceID];
                    float3 forward = normalize(star.forward);
                    half isVertical = step(0.999, forward.y);
                    float3 up = isVertical * float3(0, 0, 1) + (1 - isVertical) * float3(0, 1, 0);
                    float3 right = normalize(cross(up, forward));
                    up = normalize(cross(forward, right));

                    forward *= star.scale;
                    up *= star.scale;
                    right *= star.scale;

                    _ObjectToWorldMatrix = float4x4(
                        right.x, up.x, forward.x, star.position.x,
                        right.y, up.y, forward.y, star.position.y,
                        right.z, up.z, forward.z, star.position.z,
                        0, 0, 0, 1
                    );

                    //float4x4 scaleMatrix = float4x4(
                    //    start.scale, 0, 0, 0,
                    //    0, start.scale, 0, 0,
                    //    0, 0, start.scale, 0,
                    //    0, 0, 0, 1
                    //);

                    //_ObjectToWorldMatrix = mul(_ObjectToWorldMatrix, scaleMatrix);
                #endif
            }

            Varyings Vertex(Attributes input) {

                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float4x4 objectToWorldMatrix = UNITY_MATRIX_M;

                #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
                    objectToWorldMatrix = _ObjectToWorldMatrix;
                #endif

                float4 positionWS = mul(objectToWorldMatrix, input.positionOS);
                output.positionCS = mul(UNITY_MATRIX_VP, positionWS);

                output.uv = input.texcoord;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {
                UNITY_SETUP_INSTANCE_ID(input);

                float2 uv = input.uv * 2 - 1;
                float d = sqrt(pow(uv.x, 2) + pow(uv.y, 2));
                //d = 1 - pow((saturate(d) - 1), 8);
                d = sqrt(1 - pow((saturate(d) - 1), 2));
                //思路：尝试分两段做，范围内的较为实，范围外的虚
                float alpha = smoothstep(1, 1 - _BlurRange, d);
                _BaseColor.a = alpha;

                return _BaseColor;
            }
            ENDHLSL
        }
    }
}