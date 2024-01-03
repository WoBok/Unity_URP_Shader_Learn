Shader "URP Shader/Mask_150" {
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            ZWrite Off
            ZTest Off
            ColorMask 0
            Stencil {
                Ref 150
                Comp Always
                Pass Replace
            }
        }
    }
}