Shader "URP Shader/Mask_50" {
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            ZWrite Off
            ZTest Off
            ColorMask 0
            Stencil {
                Ref 50
                Comp Always
                Pass Replace
            }
        }
    }
}