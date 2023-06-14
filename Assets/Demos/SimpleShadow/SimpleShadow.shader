Shader "Shadow/SimpleShadow" {
    Properties {
        _LightDirection ("Light Direction", vector) = (0.3, 0.1, -0.1, 0)
        _ShadowColor ("Shadow Color", Color) = (0, 0, 0, 0)
        _ShadowFalloff ("Shadow Fall Off", float) = 1
    }
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        LOD 100

        Pass {

            Stencil {
                Ref 0
                Comp Equal
                Pass incrWrap
                Fail Keep
                ZFail Keep
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Offset -1, 0

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float4 _LightDirection;
            float4 _ShadowColor;
            float _ShadowFalloff;

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            float3 ShadowProjectPos(float4 vertPos) {

            }

            v2f vert(appdata v) {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                return o;
            }

            half4 frag(v2f i) : SV_Target {
                return half4(1, 1, 1, 1);
            }
            ENDHLSL
        }
    }
}