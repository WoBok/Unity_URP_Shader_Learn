Shader "Reflection/CubemapReflection" {
    Properties {
        _Cubemap ("Refection Cubempa", Cube) = "_Skybox" { }
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Varyings {
                float4 vertex : SV_POSITION;
                float3 worldReflection : TEXCOORD0;
            };
            samplerCUBE _Cubemap;
            CBUFFER_START(UnityPerMaterial)

            CBUFFER_END

            Varyings vert(Attributes IN) {

                Varyings OUT;
                
                OUT.vertex = TransformObjectToHClip(IN.vertex.xyz);
                
                float3 worldPos= mul(unity_ObjectToWorld,IN.vertex.xyz);
                
                float3 worldNormal = mul(IN.normal, (float3x3)unity_WorldToObject);

                float3 view = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);

                OUT.worldReflection = reflect(-view, worldNormal);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target {
                return texCUBE(_Cubemap,IN.worldReflection) ;
            }
            ENDHLSL
        }
    }
}