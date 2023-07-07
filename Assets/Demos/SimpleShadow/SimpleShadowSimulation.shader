Shader "Demo/SimpleShadow/Simple Shadow Simulation" {
    Properties {
        _LightDirection ("Light Direction", vector) = (0.3, 0.1, -0.1, 0)
        _ShadowColor ("Shadow Color", Color) = (0, 0, 0, 0.5)
        _ShadowFalloff ("Shadow Fall Off", float) = 0.1
    }
    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" }

        Pass {
            Tags { "LightMode" = "SRPDefaultUnlit" }

            Name "Shadow"

            Stencil {
                Ref 0
                Comp Equal
                Pass incrWrap
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

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
                float3 shadowPos;
                float3 worldPos = mul(unity_ObjectToWorld, vertPos).xyz;
                float3 lightDirection = normalize(_LightDirection);
                shadowPos.y = min(worldPos.y, _LightDirection.w);
                shadowPos.xz = worldPos.xz - lightDirection.xz * max(0, worldPos.y - _LightDirection.w);
                return shadowPos;
            }

            v2f vert(appdata v) {
                v2f o;
                float3 shadowPos = ShadowProjectPos(v.vertex);
                o.vertex = TransformWorldToHClip(shadowPos);
                float3 center = float3(unity_ObjectToWorld[0].w, _LightDirection.w, unity_ObjectToWorld[2].w);
                float falloff = 1 - saturate(distance(shadowPos, center) * _ShadowFalloff);
                o.color = _ShadowColor;
                o.color.a *= falloff;
                return o;
            }

            half4 frag(v2f i) : SV_Target {
                return i.color;
            }
            ENDHLSL
        }
    }
}