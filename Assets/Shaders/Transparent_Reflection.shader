Shader "Transparent/Transparent Reflection" {
    Properties {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" }
        Pass {
            Tags { "LightMode" = "UniversalForward" }
            Cull Front
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
            sampler2D _MainTex;
            float4 _MainTex_ST;
            CBUFFER_END

            v2f vert(appdata v) {
                v2f o;
                float4 worldPos = mul(UNITY_MATRIX_M, v.vertex);
                worldPos.y = -worldPos.y;
                o.vertex = mul(UNITY_MATRIX_VP, worldPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag(v2f i) : SV_Target {
                half4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDHLSL
        }
    }
}