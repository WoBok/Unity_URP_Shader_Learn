Shader "Unlit/ShaderVariants" {
    Properties {
        _MainTex ("Texture", 2D) = "white" { }
        [Toggle]  Variant ("Variant", int) = 0
        [MaterialToggle]  Variant ("Variant MaterialToggle", int) = 0
        [MaterialToggle(VARIANT_ON)] Variant ("Variant MaterialToggle(VARIANT_ON)", int) = 0
        [KeywordEnum(OFF, ON)]Variant ("Variant Keyword", int) = 0
    }
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        LOD 100

        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile VARIANT_OFF VARIANT_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v) {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                return o;
            }

            half4 frag(v2f i) : SV_Target {
                #if defined(VARIANT_ON)
                    return half4(1, 0, 0, 1);
                #elif defined(VARIANT_OFF)
                    return half4(0, 1, 0, 1);
                #endif
            }
            ENDHLSL
        }
    }
}