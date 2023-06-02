Shader "Water/ReflectionTexture" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" { }
        _ReflectionIntensity ("ReflectionIntensity", Range(0, 1)) = 0.5
    }

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
                half4 screenPos : TEXCOORD2;
            };

            sampler2D _ReflectionRT;
            sampler2D _MainTex;
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float _ReflectionIntensity;
            CBUFFER_END

            Varyings vert(Attributes IN) {

                Varyings OUT;
                
                OUT.vertex = TransformObjectToHClip(IN.vertex.xyz);

                OUT.uv = IN.uv * _MainTex_ST.xy + _MainTex_ST.zw;

                OUT.screenPos = ComputeScreenPos(OUT.vertex);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target {

                half4 mainCol = tex2D(_MainTex, IN.uv);

                half4 reflectionCol = tex2D(_ReflectionRT, IN.screenPos.xy / IN.screenPos.w);

                half4 finalCol = mainCol + reflectionCol * _ReflectionIntensity; //lerp(mainCol, reflectionCol, _ReflectionIntensity);

                return finalCol;
            }
            ENDHLSL
        }
    }
}