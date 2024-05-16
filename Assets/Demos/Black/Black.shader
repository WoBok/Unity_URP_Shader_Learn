Shader "Black/Black" {
    Properties {
        _Color ("Color", Color) = (0, 0, 0, 1)
    }

    SubShader {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            CGPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            fixed4 _Color;

            float4 Vertex(float3 positionOS : POSITION) : SV_POSITION {
                return UnityObjectToClipPos(positionOS);
            }

            fixed4 Fragment() : SV_Target {
                return _Color;
            }
            ENDCG
        }
    }
}