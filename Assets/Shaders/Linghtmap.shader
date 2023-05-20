Shader "UnityTrain/Fragment/Linghtmap" {
    Properties {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader {
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct v2f {
                float2 uv : TEXCOORD0;
                float2 uvLightmap : TEXCOORD1;
                float4 pos : POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            //Unity built-in 已经声明
            // float4 unity_LightmapST;//光照贴图Tiling和Offset存储变量？还是位置信息？
            // sampler2D unity_Lightmap;//开启光照贴图后Unity会自动为其赋值

            v2f vert(appdata_full v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv = v.texcoord;
                o.uvLightmap = v.texcoord1;

                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                o.uvLightmap *= unity_LightmapST.xy;//没有相应的宏进行控制
                o.uvLightmap += unity_LightmapST.zw;
                return o;
            }

            fixed4 frag(v2f i) : COLOR {
                fixed4 col = tex2D(_MainTex, i.uv);
                half3 lightmapCol = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLightmap));
                col.rgb *= lightmapCol;
                return col;
            }

            ENDCG
        }
    }
}