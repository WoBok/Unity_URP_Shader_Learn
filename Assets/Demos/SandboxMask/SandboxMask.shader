Shader "URP Shader/SandboxMask" {
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            ZWrite Off
            ZTest Off
            ColorMask 0
            Stencil {
                Ref 200
                Comp Always
                Pass Replace
            }
        }
    }
}