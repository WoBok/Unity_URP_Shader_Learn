Shader "Renderer Feature/ZoomBlur" {
    Properties {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float2 _FocusScreenPosition;
            int _ReferenceResolutionX;
            float _FoucsPower;
            int _FocusDetail;

            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed4 texCol = tex2D(_MainTex, i.uv);
                float2 screenPoint = _ScreenParams.xy / 2 + _FocusScreenPosition;
                return col;
            }
            ENDCG
        }
    }
}