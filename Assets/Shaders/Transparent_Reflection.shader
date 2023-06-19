Shader "Transparent/Transparent Reflection" {
    Properties {
        _MainTex ("Texture", 2D) = "white" { }
        _VisibleRange ("Visible Range", float) = 1
        _GroundHight ("Ground Hight", float) = 0
        _FadeRange ("Fade Range", Range(0, 0.5)) = 0
        _FadeIntensity ("Fade Intensity", Range(0, 1)) = 0
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
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float3 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _Color;
            float _VisibleRange;
            float _GroundHight;
            float _FadeRange;
            float _FadeIntensity;
            CBUFFER_END

            v2f vert(appdata v) {
                v2f o;
                float4 worldPos = mul(UNITY_MATRIX_M, v.positionOS);
                worldPos.y = -worldPos.y;

                float dis = distance(worldPos, GetCameraPositionWS());
                o.positionCS = mul(UNITY_MATRIX_VP, worldPos);
                float visibleAlpha = saturate(1 - (dis / _VisibleRange));
                float hightAlpha = 1 - saturate(-worldPos.y * _FadeRange) * (1-_FadeIntensity);

                o.uv = half3(TRANSFORM_TEX(v.uv, _MainTex), visibleAlpha * hightAlpha);

                return o;
            }

            half4 frag(v2f i) : SV_Target {
                half4 col = tex2D(_MainTex, i.uv);
                col.a = i.uv.z;
                return col;
            }
            ENDHLSL
        }
    }
}