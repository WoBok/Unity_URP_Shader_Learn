Shader "URP Shader/MASK_1" {
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            ColorMask 0
            ZWrite Off

            Stencil {
                Ref 185
                Comp Always
                Pass Replace
            }
        }
    }
}