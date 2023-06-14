Shader "Light/Color" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" { }
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile _ LIGHTMAP_ON


            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 lightmapUV : TEXCOORD1;
            };

            struct Varyings {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 lightmapUV : TEXCOORD1;
            };
            
            sampler2D _MainTex;
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float c_r=1;
            float c_g=1;
            float c_b=1;
            CBUFFER_END

            Varyings vert(Attributes IN) {

                Varyings OUT;
                
                OUT.vertex = TransformObjectToHClip(IN.vertex.xyz);

                OUT.uv = IN.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                OUT.lightmapUV = IN.lightmapUV * unity_LightmapST.xy + unity_LightmapST.zw;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target {

                half3 albedo = tex2D(_MainTex, IN.uv).rgb;
                //half3 color = lerp(albedo, half4(1, 0, 0, 1), 0.5);
                return half4(albedo.r*c_r,albedo.g*c_g,albedo.b*c_b, 1);
            }
            ENDHLSL
        }
    }
}