Shader "URP Shader/Mask_100" {
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            ZWrite Off
            ZTest Off
            ColorMask 0
            Stencil {
                Ref 100
                Comp Always
                Pass Replace
            }
        }
    }
}