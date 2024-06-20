Shader "Geometry Shader/Star Sea" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" { }
        [HDR]_MainColor ("Color", Color) = (1, 1, 1, 1)
        _NoiseFactor ("Noise", Float) = 1
        _Speed ("Speed", Float) = 1
    }

    SubShader {
        Pass {
            Tags { "RenderType" = "Opaque" }
            LOD 200

            CGPROGRAM
            #pragma target 4.0
            #pragma vertex VS_Main
            #pragma geometry GS_Main
            #pragma fragment FS_Main

            #include "UnityCG.cginc"
            #include "noiseSimplex.cginc"

            uniform sampler2D _MainTex;

            struct v2g {
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct g2f {
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            fixed4 _MainColor;
            float _NoiseFactor;
            float _Speed;

            float GetNoise(float2 uv, float noiseFactor) {
                return perlin(uv.x * noiseFactor * _NoiseFactor + (_Time.y * _Speed * 100), uv.y * noiseFactor * _NoiseFactor + (_Time.y * _Speed * 100));
            }

            v2g VS_Main(appdata_base v) {
                v2g o = (v2g)0;

                float4 posOffset = float4(GetNoise(v.texcoord, 1000), GetNoise(v.texcoord, 1200), GetNoise(v.texcoord, 900), 0);

                v.vertex += posOffset;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;

                return o;
            }

            [maxvertexcount(3)]
            void GS_Main(triangle v2g p[3], inout PointStream<g2f> pStream) {
                for (int i = 0; i < 3; i++) {
                    g2f o = (g2f)0;
                    o.pos = p[i].pos;
                    o.normal = p[i].normal;
                    o.uv = p[i].uv ;
                    pStream.Append(o);
                }
            }

            float4 FS_Main(g2f i) : COLOR {
                return tex2D(_MainTex, i.uv) * _MainColor;
            }

            ENDCG
        }
    }
}