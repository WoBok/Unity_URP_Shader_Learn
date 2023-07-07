Shader "Demo/AnimMapBaker/AnimMapBaker" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _AnimMap ("AnimMap", 2D) = "white" { }
        _AnimLen ("Anim Length", Float) = 0
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
            half4 _BaseColor;
            float _AnimLen;
            sampler2D _AnimMap;
            float4 _AnimMap_TexelSize;//贴图_AnimMap的像素尺寸大小，值： Vector4(1 / width, 1 / height, width, height)

            UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)

            UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

            Varyings Vertex(Attributes input, uint vid : SV_VertexID) {
                Varyings output;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                float f = _Time.y / _AnimLen;//如AnimLen总时长为5s，那么当5秒时从0采样到1，利用大于1时重复采样贴图的特性，
                                                              //则AnimLen的时常内播放完整个动画
                //fmod(f, 1.0);
                float animMap_x = (vid + 0.5) * _AnimMap_TexelSize.x;
                float animMap_y = f;
                float4 pos = tex2Dlod(_AnimMap, float4(animMap_x, animMap_y, 0, 0));
                
                output.positionCS = mul(UNITY_MATRIX_MVP, pos);
                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));
                output.uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {
                UNITY_SETUP_INSTANCE_ID(input);

                half4 albedo = tex2D(_BaseMap, input.uv);

                half4 diffuse = albedo * (dot(input.normalWS, normalize(_MainLightPosition.xyz)) * 0.5 + 0.5);

                return diffuse * _BaseColor;
            }
            ENDHLSL
        }
    }
}