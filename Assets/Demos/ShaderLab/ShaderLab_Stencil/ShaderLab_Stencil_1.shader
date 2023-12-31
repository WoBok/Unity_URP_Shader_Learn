Shader "Demo/ShaderLab Syntax/Stencil/Stencil_1" {

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass {

            Stencil {
                Ref 55
                Comp Always
                Pass Replace//Replace	2	将参考值写入缓冲区。
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v) {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                return o;
            }

            half4 frag(v2f i) : SV_Target {
                return half4(1, 0, 0, 1);
            }
            ENDHLSL
        }
    }
}