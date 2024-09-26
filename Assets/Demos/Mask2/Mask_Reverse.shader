
Shader "URP Shader/Mask_Reverse" {
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            ColorMask 0
            ZWrite Off

            Stencil {
                Ref 1
                Comp Always
                Pass Replace
            }
        }
    }
}
