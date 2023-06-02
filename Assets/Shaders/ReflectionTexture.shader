Shader "Water/ReflectionTexture" {
    Properties { }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            Tags { "LightMode" = "UniversalForward" }
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes {
                half4 vertex : POSITION;
                half2 uv : TEXCOORD0;
            };

            struct Varyings {
                half4 vertex : SV_POSITION;
                half2 uv : TEXCOORD1;
            };

            sampler2D _ReflectionRT;
            CBUFFER_START(UnityPerMaterial)

            CBUFFER_END

            Varyings vert(Attributes IN) {

                Varyings OUT;
                
                OUT.vertex = TransformObjectToHClip(IN.vertex.xyz);

                OUT.uv = IN.uv;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target {

                half4 col = tex2D(_ReflectionRT, IN.uv);

                return col;
            }
            ENDHLSL
        }
    }
}