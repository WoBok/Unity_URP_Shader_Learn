Shader "Geometry Shader/LineStream" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" { }
        _MainColor ("Color", Color) = (1, 1, 1, 1)
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

            // Vertex Shader
            v2g VS_Main(appdata_base v) {
                v2g o = (v2g)0;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.uv = v.texcoord;

                return o;
            }

            fixed4 _MainColor;

            // Geometry Shader
            [maxvertexcount(3)]
            void GS_Main(triangle v2g p[3], inout LineStream<g2f> lStream) {
                for (int i = 0; i < 3; i++) {
                    g2f o = (g2f)0;
                    o.pos = p[i].pos;
                    o.normal = p[i].normal;
                    o.uv = p[i].uv ;
                    //将每个顶点添加到LineStream流里
                    lStream.Append(o);
                }
            }

            // Fragment Shader
            float4 FS_Main(g2f i) : COLOR {
                return tex2D(_MainTex, i.uv) * _MainColor;
            }

            ENDCG
        }
    }
}