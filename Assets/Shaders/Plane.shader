Shader "Reflection/Plane" {
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            Blend OneMinusDstAlpha DstAlpha
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            float4 vert(float4 vertex : POSITION) : SV_POSITION {
                return TransformObjectToHClip(vertex.xyz);
            }

            half4 frag(float4 vertex : POSITION) : SV_Target {
                //return half4(GlossyEnvironmentReflection(float3(0, 1, 0), 1, 1), 1);
                return half4(0,0,1, 1);

            }
            ENDHLSL
        }
    }
}