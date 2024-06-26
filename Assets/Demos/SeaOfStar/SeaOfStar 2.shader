Shader "URP Shader/SeaOfStar 2" {
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
            #pragma instancing_options procedural:SetupPosition

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
                    float movementSpeed;
                    float rotationSpeed;
                    float scale;
                };

                StructuredBuffer<Star> starts;//不可为RW

                float3 _Position ;
                float _Scale;
            #endif

            void SetupPosition() {
                #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
                    _Position = starts[unity_InstanceID].position;
                    _Scale = starts[unity_InstanceID].scale;
                #endif
            }

            Varyings Vertex(Attributes input) {

                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float3 addPosition = float3(0, 0, 0);
                #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
                    input.positionOS.xyz *= _Scale;
                    input.positionOS.xyz += TransformWorldToObject(_Position);
                    //viewDirection = _WorldSpaceCameraPos - _Position;
                    addPosition = TransformWorldToObject(_Position);
                #endif

                //float3 forward = normalize(TransformWorldToObject(_WorldSpaceCameraPos - addPosition));
                //half isVertical = step(0.999, forward.y);
                //float3 up = isVertical * float3(0, 0, 1) + (1 - isVertical) * float3(0, 1, 0);
                //float3 right = normalize(cross(up, forward));
                //up = normalize(cross(forward, right));

                //float3 newPos = input.positionOS.x * - right + input.positionOS.y * up + input.positionOS.z * forward;

                //output.positionCS = mul(UNITY_MATRIX_MVP, float4(newPos, input.positionOS.w));

                float4 ori = mul(UNITY_MATRIX_MV, float4(0, 0, 0, 1));
                float4 vt = input.positionOS;
                float2 r1 = float2(unity_ObjectToWorld[0][0], unity_ObjectToWorld[0][2]);
                float2 r2 = float2(unity_ObjectToWorld[2][0], unity_ObjectToWorld[2][2]);
                vt.xy = vt.x * r1 + vt.z * r2;
                vt.z = 0;
                vt.xyz += ori.xyz;
                output.positionCS = mul(UNITY_MATRIX_P, vt);

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