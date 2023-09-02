Shader "Demo/OutLine/OutLine" {
    Properties {
        _Color ("outline color", color) = (1, 1, 1, 1)
        _Width ("outline width", range(0, 1)) = 0.2
    }
    Subshader {
        Pass {
            Tags { "LightMode" = "UniversalForward" }

            ColorMask 0
            ZWrite Off
            ZTest Off
            
            Stencil {
                Ref 1
                Comp Always
                Pass Replace
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float4 vert(float4 pos : POSITION) : SV_POSITION {
                return TransformObjectToHClip(pos.xyz);
            }
            
            half4 frag() : SV_Target {
                return half4(0, 0, 0, 0);
            }
            ENDHLSL
        }
        
        Pass {
            ZTest Off
            
            Stencil {
                Ref 1
                Comp NotEqual
                Pass Keep
            }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2f {
                float4 vertex : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            half _Width;
            CBUFFER_END

            v2f vert(appdata v) {
                v2f o;
                v.vertex.xyz += _Width * normalize(v.normal) * length(v.vertex);
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }
            
            half4 frag(v2f i) : SV_Target {
                return _Color;
            }
            ENDHLSL
        }
    }
}