Shader "xxxy/WithoutClip"
{
    Properties
    {
        _MainTex ("MainTexture", 2D) = "white" {}
        _DisolveRange("DisolveRange",Range(0,10)) = 0
        _Density("Density",float) = 10
        _Color01("Color01",Color) = (1,1,1,1)
        _Color02("Color02",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" }

        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _DisolveRange, _Density;
            half4 _Color01, _Color02;

            //2D噪声图生成-伪随机(经验数值)
            float2 hash22(float2 p) 
            {
                p = float2(dot(p,float2(127.1,311.7)),dot(p,float2(269.5,183.3)));
                return -1.0 + 2.0*frac(sin(p)*43758.5453123);
            }
            //柏林噪声
            float perlin_noise(float2 p) 
            {				
                float2 pi = floor(p);
                float2 pf = p - pi;
                float2 w = pf * pf*(3.0 - 2.0*pf);
                return lerp(lerp(dot(hash22(pi + float2(0.0, 0.0)), pf - float2(0.0, 0.0)),
                dot(hash22(pi + float2(1.0, 0.0)), pf - float2(1.0, 0.0)), w.x),
                lerp(dot(hash22(pi + float2(0.0, 1.0)), pf - float2(0.0, 1.0)),
                dot(hash22(pi + float2(1.0, 1.0)), pf - float2(1.0, 1.0)), w.x), w.y);
            }


            struct appdata
            {
                float4 vertex : POSITION;
                float4 color  : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv     : TEXCOORD0;
                float4 color  : TEXCOORD1;
            };

            

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 c;
                half4 mainTex = tex2D(_MainTex,i.uv);
                c = mainTex;
                _DisolveRange *= 0.2;

                //溶解实现
                fixed nosie = perlin_noise(i.uv*_Density);
                fixed clip = i.color.a;
                clip *= saturate((nosie +1)*(1/_DisolveRange));
                clip = step(1,clip);
                c *= clip;
                //边缘过渡
                fixed dissovleRim = saturate((nosie+1 - _DisolveRange)/(_DisolveRange+0.15 - _DisolveRange));
                //颜色过渡
                fixed4 rimColor = lerp(_Color01,_Color02,dissovleRim);
                rimColor *= frac(dissovleRim);
                //c += step(0.2,rimColor);

                return c;
            }
            ENDCG
        }
    }
}