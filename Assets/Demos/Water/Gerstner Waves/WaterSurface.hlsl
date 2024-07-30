#ifndef WATER_SURFACE_INCLUDED
#define WATER_SURFACE_INCLUDED

#include "WaterLighting.hlsl"
#include "WaterColor.hlsl"
#ifdef _NORMALSWITCH_ON
    #include "WaterNormal.hlsl"
#endif

void InitializeInputData(Varyings input, out InputData inputData) {
    inputData = (InputData)0;

    #ifdef _NORMALSWITCH_ON
        float3 normalTS = GetNormal(input.normalWS, input.uv);

        float sgn = input.tangentWS.w;
        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);

        float3 normal = TransformTangentToWorld(normalTS, tangentToWorld);
        inputData.normalWS = normalize(normal);
    #else
        inputData.normalWS = normalize(input.normalWS);
    #endif

    inputData.viewDirectionWS = normalize(_WorldSpaceCameraPos - input.positionWS);
    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, input.normalWS);
    inputData.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    inputData.positionWS = input.positionWS;
}

void InitializeSurfaceData(Varyings input, out SurfaceData surfaceData) {
    surfaceData = (SurfaceData)0;
    surfaceData.metallic = _Metallic;
    surfaceData.smoothness = _Smoothness;
    surfaceData.occlusion = 1;

    half4 waterColor = 0;
    #ifdef _VERTEXTRANSPARENT_ON
        waterColor = WaterColorVertexTransparent(input.vertexAlpha);
    #else
        waterColor = WaterColor(input.screenPos, input.uv, input.positionCS, input.positionWS);
    #endif
    surfaceData.albedo = waterColor.rgb;
    surfaceData.alpha = waterColor.a;
}

half4 Surface(Varyings input) {
    InputData inputData;
    InitializeInputData(input, inputData);

    SurfaceData surfaceData;
    InitializeSurfaceData(input, surfaceData);

    half4 color = UniversalFragmentPBR(inputData, surfaceData);

    color.rgb += GetFresnelColor(inputData);
    color.rgb += GetAdditionalLightColor(inputData);

    return color;
}
#endif