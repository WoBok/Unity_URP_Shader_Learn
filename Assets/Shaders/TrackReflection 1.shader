Shader "Reflection/TrackReflection 1" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" { }

        _Alpha ("Alpha", Range(0, 1)) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            //ZTest Equal
            ZWrite On
            //Cull Front
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            CBUFFER_START(UnityPerMaterial)
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Alpha;
            CBUFFER_END

            Varyings vert(Attributes IN) {

                Varyings OUT;

                OUT.vertex = TransformObjectToHClip(IN.vertex);

                OUT.uv = IN.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target {

                float4 color = tex2D(_MainTex, IN.uv);

                color.a *= _Alpha;

                return color;
            }
            ENDHLSL
        }
    }
}