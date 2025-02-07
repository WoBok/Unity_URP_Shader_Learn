Shader "Unlit/UVSpread"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Center ("Center", Range(0,1)) = 0.65
        _Progress ("Progress", Range(0,1)) = 0
        _EffectColor ("Effect Color", Color) = (1,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Center;
            float _Progress;
            fixed4 _EffectColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float U = i.uv.x;
                float center = _Center;
                float width = _Progress * 0.5; // 扩散宽度，最大0.5到达0.15

                // 计算循环后的距离
                float d = abs(U - center);
                d = min(d, 1 - d);

                // 判断是否在扩散区域内
                if (d <= width)
                    return _EffectColor;
                else
                    return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}