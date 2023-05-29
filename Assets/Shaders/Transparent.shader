Shader "Transparent/Transparent" {
    Properties {
        _MainTex ("Texture", 2D) = "white" { }
        _Alpha ("Alpha", float) = 1
    }
    SubShader {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" "RenderType" = "Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent" }
        Pass
        {
            ZWrite On
            ColorMask 0 
        }
        Pass {
            Tags {"LightMode"="UniversalForward"}
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Back
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
            float _Alpha;
            CBUFFER_END

            v2f vert(appdata v) {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag(v2f i) : SV_Target {
                half4 col = tex2D(_MainTex, i.uv);
                col.a = _Alpha;
                return col;
            }
            ENDHLSL
        }
    }
}