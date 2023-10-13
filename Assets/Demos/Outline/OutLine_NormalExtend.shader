Shader "Demo/Outline/OutLine_NormalExtend" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 0)
        _Outline ("Outline", float) = 1
        _A ("A", float) = 1
        _B ("B", float) = 0
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            Tags { "LightMode" = "SRPDefaultUnlit" }

            Stencil {
                Ref 1
                Comp Always
                Pass Replace
            }
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
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
                
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

                output.uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                half4 albedo = tex2D(_BaseMap, input.uv);

                return albedo * _BaseColor;
            }
            ENDHLSL
        }

        Pass {
            Tags { "LightMode" = "UniversalForward" }

            Stencil {
                Ref 1
                Comp NotEqual
            }
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings {
                float4 positionCS : SV_POSITION;
            };
            
            CBUFFER_START(UnityPerMaterial)
            half4 _OutlineColor;
            half _Outline;
            half _A;
            half _B;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                //float4 pos = mul(UNITY_MATRIX_MV, input.positionOS);
                //float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, input.normalOS);
                //normal.z = -0.5;
                //pos = pos + float4(normalize(normal), 0) * _Outline;
                //output.positionCS = mul(UNITY_MATRIX_P, pos);

                output.positionCS = TransformObjectToHClip(input.positionOS);
                float3 normalVS = mul((float3x3)UNITY_MATRIX_IT_MV, input.normalOS);
                float2 offset = mul((float2x2)UNITY_MATRIX_P, normalVS.xy);
                output.positionCS.xy += offset * _Outline ;

                //input.positionOS.xyz += normalize(input.normalOS).xyz * _Outline;
                //output.positionCS = TransformObjectToHClip(input.positionOS);

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {
                return _OutlineColor;
            }
            ENDHLSL
        }
    }
}