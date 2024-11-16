#ifndef PBR_BRDF_INCLUDED
#define PBR_BRDF_INCLUDED

#define DIELECTRICF0 half4(0.04, 0.04, 0.04, 1.0 - 0.04)
#define NON_ZERO  6.103515625e-5

struct PBRData {
    //Todo: 重新组织数据，可将difuuseColor与specularColor，roughness等的计算放入InitializeBRDFData中，在PBRLighting中先初始化再使用
    half3 diffuseColor, specularColor, bakedGI;
    half roughness, oneMinusReflectivity, occlusion,alpha;
    float3 positionWS, normalWS, viewDirWS;
};

//Unity GlobalIllumination BRDFData
void InitializeBRDFData(PBRData pbrData, out BRDFData outBRDFData) {
    outBRDFData = (BRDFData)0;
    outBRDFData.diffuse = pbrData.diffuseColor;
    outBRDFData.specular = pbrData.specularColor;
    outBRDFData.reflectivity = 1 - pbrData.oneMinusReflectivity;

    outBRDFData.perceptualRoughness = pbrData.roughness;
    outBRDFData.roughness = max(outBRDFData.perceptualRoughness * outBRDFData.perceptualRoughness, HALF_MIN_SQRT);
    outBRDFData.roughness2 = max(outBRDFData.roughness * outBRDFData.roughness, HALF_MIN);
    outBRDFData.grazingTerm = saturate(1 - pbrData.roughness + outBRDFData.reflectivity);
    outBRDFData.normalizationTerm = outBRDFData.roughness * half(4.0) + half(2.0);
    outBRDFData.roughness2MinusOne = outBRDFData.roughness2 - half(1.0);
    outBRDFData.diffuse *= pbrData.alpha;//Todo: 使用透明材质测试和Lit材质做比较，在透明度较低的时候漫反射是否会被压暗

}
//Unity GlobalIllumination BRDFData

half3 DisneyDiffuse(half roughness, half3 diffuseColor, half ndotv, half ndotl, half ldoth) {
    half fd90 = 0.5 + 2 * roughness * ldoth * ldoth;

    half lightScatter = 1 + (fd90 - 1) * pow(1 - ndotl, 5);
    half viewScatter = 1 + (fd90 - 1) * pow(1 - ndotv, 5);

    //diffuseColor /= PI;

    return diffuseColor * lightScatter * viewScatter;
}

half3 Fresnel(half3 f0, half ldoth) {
    return f0 + (1 - f0) * pow((1 - ldoth), 5);
}

float GGX(float roughness, float ndoth) {
    float a2 = roughness * roughness;
    float d = (ndoth * a2 - ndoth) * ndoth + 1;
    return a2 / max(PI * d * d, NON_ZERO);
}

//http://jcgt.org/published/0003/02/03/paper.pdf
float SmithJointGGX(float roughness, float ndotl, float ndotv) {
    half a2 = roughness * roughness;

    half lambdaV = ndotl * sqrt((-ndotv * a2 + ndotv) * ndotv + a2);
    half lambdaL = ndotv * sqrt((-ndotl * a2 + ndotl) * ndotl + a2);

    return 1 / (2 * max(NON_ZERO, lambdaV + lambdaL));
}
#endif