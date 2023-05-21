Shader "Renderer Feature/ZoomBlur_FillValue" {
    Properties {
        _MainTex ("Texture", 2D) = "white" { }
        _FocusScreenPositionX ("FocusScreenPositionX", float) = 0
        _FocusScreenPositionY ("FocusScreenPositionY", float) = 0
        _ReferenceResolutionX ("ReferenceResolutionX", int) = 1334
        _FoucsPower ("FoucsPower", float) = 45
        _FocusDetail ("FocusDetail", int) = 5
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
            float _FocusScreenPositionX;
            float _FocusScreenPositionY;
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
                _FocusScreenPosition = float2(_FocusScreenPositionX, _FocusScreenPositionY);
                float2 screenPoint = _ScreenParams.xy / 2 + _FocusScreenPosition;
                float2 uv = i.uv;
                float2 mousePos = (screenPoint.xy / _ScreenParams.xy);
                float2 focus = uv - mousePos;
                fixed aspectX = _ScreenParams.x / _ReferenceResolutionX;
                float4 outColor = float4(0, 0, 0, 1);
                for (int i = 0; i < _FocusDetail; i++) {
                    float power = 1.0 - _FoucsPower * (1.0 / _ScreenParams.x * aspectX) * float(i);
                    outColor.rgb += tex2D(_MainTex, focus * power + mousePos).rgb;
                }
                outColor.rgb *= 1.0 / float(_FocusDetail);
                return outColor;
            }
            ENDCG
        }
    }
}