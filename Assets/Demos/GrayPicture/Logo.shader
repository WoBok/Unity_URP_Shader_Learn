Shader "URP Shader/UI/Logo" {
    Properties {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" }

        Pass {

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                half4 color : COLOR;
            };

            struct Varyings {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
                half4 color : COLOR;
            };
            
            sampler2D _MainTex;
            CBUFFER_START(UnityPerMaterial)
            CBUFFER_END


            Varyings Vertex(Attributes input) {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.texcoord;
                output.color = input.color ;
                return output;
            }

            float4 Fragment(Varyings input) : SV_Target {
                half4 color = tex2D(_MainTex, input.uv)  ;
                color.rgb*= input.color.rgb;
                half luminance = dot(color.rgb, half3(0.299, 0.587, 0.114));
                half3 greyScale = half3(luminance, luminance, luminance);
                return half4(lerp(greyScale, color.rgb, input.color.a), color.a);
            }
            ENDHLSL
        }
    }
}