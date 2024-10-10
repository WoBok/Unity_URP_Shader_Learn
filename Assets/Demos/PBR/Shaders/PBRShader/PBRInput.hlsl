#ifndef PBR_INPUT_INCLUDED
#define PBR_INPUT_INCLUDED

struct Attributes {
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 texcoord : TEXCOORD0;
};

struct Varyings {
    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    half3 normalWS : TEXCOORD2;
    #ifdef _NORMALSWITCH_ON
        half3 tangentWS : TEXCOORD3;
        half3 bitangentWS : TEXCOORD4;
    #endif
    float4 positionCS : SV_POSITION;
};

sampler2D _AlbedoMap;

#ifdef _METALLICSWITCH_ON
    sampler2D _MetallicMap;
#endif

#ifdef _NORMALSWITCH_ON
    sampler2D _NormalMap;
#endif

sampler2D _OcclusionMap;

CBUFFER_START(UnityPerMaterial)
half3 _PBRLightDirection;
half3 _PBRLightColor;
half _PBRLightIntensity;

float4 _AlbedoMap_ST;
half4 _BaseColor;

half _Smoothness;
float _Metallic;
#ifdef _METALLICSWITCH_ON
    float _MetallicScale;
#endif

#ifdef _NORMALSWITCH_ON
    float _NormalScale;
#endif
CBUFFER_END

half3 SampleNormalWSFrag(Varyings input) {
    #ifdef _NORMALSWITCH_ON
        half3 normalTS = UnpackNormal(tex2D(_NormalMap, input.uv));
        normalTS.xy *= _NormalScale;
        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
        return mul(normalTS.xyz, tangentToWorld);
    #else
        return input.normalWS.xyz;
    #endif
}

half2 SampleMetallicGloss(float2 uv) {
    half2 metallicGloss;
    #ifdef _METALLICSWITCH_ON
        metallicGloss = tex2D(_MetallicMap, uv).ra;
        metallicGloss.g *= _MetallicScale;
    #else
        metallicGloss.r = _Metallic;
        metallicGloss.g = _Smoothness;
    #endif
    return metallicGloss;
}

void InitializeLightingData(out LightingData lightingData) {
    _PBRLightDirection = _MainLightPosition.xyz;
    _PBRLightColor = _MainLightColor.rgb;
    _PBRLightIntensity = 1;

    lightingData.direction = _PBRLightDirection;
    lightingData.color = _PBRLightColor * _PBRLightIntensity;
}

void InitializeBRDFData(Varyings input, out BRDFData brdfData) {
    half4 albedo = tex2D(_AlbedoMap, input.uv) * _BaseColor;

    half2 metallicGloss = SampleMetallicGloss(input.uv);
    half oneMinusReflectivity = DIELECTRICF0.a - metallicGloss.r * DIELECTRICF0.a;

    brdfData.diffuseColor = albedo * oneMinusReflectivity;
    brdfData.specularColor = lerp(DIELECTRICF0.rgb, albedo, metallicGloss.r);

    brdfData.roughness = 1 - metallicGloss.g;

    brdfData.normalWS = SampleNormalWSFrag(input);
    brdfData.viewDirWS = normalize(_WorldSpaceCameraPos - input.positionWS);
}

#endif