Shader "Reflection/TrackReflection" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" { }

        _Alpha ("Alpha", Range(0, 1)) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            ZTest Greater
            ZWrite On
            Cull Front
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            CBUFFER_START(UnityPerMaterial)
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Alpha;
            CBUFFER_END

            Varyings vert(Attributes IN) {

                Varyings OUT;

                float4 worldPos = mul(UNITY_MATRIX_M, IN.vertex);
                worldPos.y = -worldPos.y;

                OUT.vertex = mul(UNITY_MATRIX_VP, worldPos);

                OUT.uv = IN.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target {

                float4 color = tex2D(_MainTex, IN.uv);

                color.a *= _Alpha;

                return color;
            }
            ENDHLSL
        }
    }
}