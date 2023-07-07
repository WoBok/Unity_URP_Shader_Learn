Shader "Demo/ShaderLab Syntax/Offset"
{
    Properties
    {
        _OffsetFactor ("Offset Factor", Float) = 0
        _OffsetUnits ("Offset Units", Float) = 0
        _Color ("Main Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Offset [_OffsetFactor], [_OffsetUnits]
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 wnormal : NORMAL;
            };
            fixed4 _Color;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.wnormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return _Color * (dot(normalize(_WorldSpaceLightPos0.xyz), i.wnormal) * 0.5 + 0.5);
            }
            ENDCG
        }
    }
}

