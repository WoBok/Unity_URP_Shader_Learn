#ifndef WATER_INPUT_INCLUDED
#define WATER_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes {
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    half4 color : COLOR;
    float2 texcoord : TEXCOORD0;
    float2 staticLightmapUV : TEXCOORD1;
};

struct Varyings {
    float2 uv : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
    float3 positionWS : TEXCOORD2;
    half4 tangentWS : TEXCOORD3;
    float4 screenPos : TEXCOORD4;
    half vertexAlpha : TEXCOORD5;
    float4 positionCS : SV_POSITION;
    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 6);
};

sampler2D _FoamMap;
float4 _FoamMap_ST;
half4 _BaseColor;
float _Smoothness, _Metallic;

#endif