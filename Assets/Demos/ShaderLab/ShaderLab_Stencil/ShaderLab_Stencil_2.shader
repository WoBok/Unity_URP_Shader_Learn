Shader "Demo/ShaderLab Syntax/Stencil/Stencil_2" {

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Pass {

            Stencil {
                Ref 50
                Comp Less//Less	2	在参考值小于模板缓冲区中的当前值时渲染像素。Greater	5	在参考值大于模板缓冲区中的当前值时渲染像素。
                Pass Keep
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
                return half4(0, 1, 0, 1);
            }
            ENDHLSL
        }
    }
}