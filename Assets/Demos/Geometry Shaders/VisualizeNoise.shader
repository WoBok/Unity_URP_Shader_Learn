Shader "Custom/VisualizeNoise" {
    Properties {
        _Wind ("Wind", Vector) = (1, 1, 1, 1)
        _NoiseFactor ("Noise", Float) = 1
        _Speed ("Speed", Float) = 1
    }
    SubShader {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "noiseSimplex.cginc"
            
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float3 position : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            float4 _Wind;
            float _NoiseFactor;
            float _Speed;

            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.position = v.vertex.xyz;
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float2 offset = (i.position.xz + _Wind.xy * _Time.y * _Wind.z) * _Wind.w;
                //float noise = perlin(offset.x, offset.y);
                //float noise = snoise(i.uv*100);
                float noise = perlin(i.uv.x * 1000 * _NoiseFactor + (_Time.y * _Speed * 100), i.uv.y * 1000 * _NoiseFactor + (_Time.y * _Speed * 100));
                //float noise = snoise(i.vertex/100);
                return fixed4(noise, noise, noise, 1);
            }
            ENDCG
        }
    }
}