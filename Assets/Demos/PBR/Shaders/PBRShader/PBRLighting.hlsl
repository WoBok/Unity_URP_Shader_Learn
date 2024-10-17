#ifndef PBR_LIGHTING_INCLUDED
#define PBR_LIGHTING_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "PBRBRDF.hlsl"

struct PBRLightingData {
    half3 direction;
    half3 color;
};

half4 PBRLighting(PBRLightingData pbrLightingData, PBRData pbrData) {
    float3 halfDir = normalize(pbrLightingData.direction + pbrData.viewDirWS);

    half ndotv = abs(dot(pbrData.normalWS, pbrData.viewDirWS));
    half ndotl = saturate(dot(pbrData.normalWS, pbrLightingData.direction));
    half ndoth = saturate(dot(pbrData.normalWS, halfDir));
    half ldoth = saturate(dot(pbrLightingData.direction, halfDir));

    half3 diffuseTerm = DisneyDiffuse(pbrData.roughness, pbrData.diffuseColor, ndotv, ndotl, ldoth) * ndotl;

    half roughness = max(pbrData.roughness * pbrData.roughness, 0.002);
    half3 F = Fresnel(pbrData.specularColor, ldoth);
    half G = SmithJointGGX(roughness, ndotl, ndotv);
    half D = GGX(roughness, ndoth);
    half3 specularTerm = (F * D * G) * PI;/// (4 * ndotl * ndotv);//
    specularTerm = max(0, specularTerm * ndotl);

    half3 color = diffuseTerm * pbrLightingData.color + specularTerm * pbrLightingData.color;

    BRDFData brdfData;
    InitializeBRDFData(pbrData, brdfData);
    color += GlobalIllumination(brdfData, pbrData.bakedGI, pbrData.occlusion, pbrData.positionWS, pbrData.normalWS, pbrData.viewDirWS);

    return half4(color, 1);
}
#endif