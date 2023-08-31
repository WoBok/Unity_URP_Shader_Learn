Shader "WoBok/CameraFade" {
    Properties {
        _Alpha ("Alpha", Range(0, 1)) = 0
    }
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" }

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest Always
            Cull Front

            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float _Alpha;
            CBUFFER_END

            float4 Vertex(float4 vertex : POSITION) : SV_POSITION {
                return TransformObjectToHClip(vertex.xyz);
            }

            half4 Fragment() : SV_Target {
                return half4(0, 0, 0, _Alpha);
            }
            ENDHLSL
        }
    }
}