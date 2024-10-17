#ifndef PBR_INPUT_INCLUDED
#define PBR_INPUT_INCLUDED

struct Attributes {
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 texcoord : TEXCOORD0;
    float2 staticLightmapUV : TEXCOORD1;
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
    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 5);
};

sampler2D _AlbedoMap;

#ifdef _METALLICSWITCH_ON
    sampler2D _MetallicMap;
#endif

#ifdef _NORMALSWITCH_ON
    sampler2D _NormalMap;
#endif

#ifdef _OCCLUSIONSWITCH_ON
    sampler2D _OcclusionMap;
#endif

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

#ifdef _OCCLUSIONSWITCH_ON
    half _OcclusionScale;
#endif

#ifdef _NORMALSWITCH_ON
    float _NormalScale;
#endif

#ifdef _ALPHACLIPPING_ON
    half _AlphaClipThreshold;
#endif
CBUFFER_END

half3 SampleNormalWSFrag(Varyings input) {
    #ifdef _NORMALSWITCH_ON
        half3 normalTS = UnpackNormal(tex2D(_NormalMap, input.uv));
        normalTS.xy *= _NormalScale;
        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
        return normalize(mul(normalTS.xyz, tangentToWorld));
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

half SampleOcclusion(float2 uv) {
    #ifdef _OCCLUSIONSWITCH_ON
        half occlusion = tex2D(_OcclusionMap, uv).g;
        return 1 - _OcclusionScale + occlusion * _OcclusionScale;
    #else
        return 1;
    #endif
}

void InitializeLightingData(out PBRLightingData pbrLightingData) {
    _PBRLightDirection = _MainLightPosition.xyz;
    _PBRLightColor = _MainLightColor.rgb;
    _PBRLightIntensity = 1;

    pbrLightingData.direction = _PBRLightDirection;
    pbrLightingData.color = _PBRLightColor * _PBRLightIntensity;
}

void InitializeBRDFData(Varyings input, out PBRData pbrData) {
    //ÐÞ¸ÄÎªInitializeInputData
    half4 texColor = tex2D(_AlbedoMap, input.uv);

    pbrData.alpha = texColor.a * _BaseColor.a;
    #ifdef _ALPHACLIPPING_ON
        clip(pbrData.alpha - _AlphaClipThreshold);
    #endif

    half2 metallicGloss = SampleMetallicGloss(input.uv);
    half oneMinusReflectivity = DIELECTRICF0.a - metallicGloss.r * DIELECTRICF0.a;

    pbrData.oneMinusReflectivity = oneMinusReflectivity;

    half3 albedo = texColor.xyz * _BaseColor.rgb;
    pbrData.diffuseColor = albedo * oneMinusReflectivity;
    pbrData.specularColor = lerp(DIELECTRICF0.rgb, albedo, metallicGloss.r);

    pbrData.roughness = 1 - metallicGloss.g;

    pbrData.positionWS = input.positionWS;
    pbrData.normalWS = SampleNormalWSFrag(input);
    pbrData.viewDirWS = normalize(_WorldSpaceCameraPos - input.positionWS);

    pbrData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, input.normalWS);

    pbrData.occlusion = SampleOcclusion(input.uv);
}
#endif