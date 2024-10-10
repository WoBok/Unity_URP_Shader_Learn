#ifndef PBR_LIGHTING_INCLUDED
#define PBR_LIGHTING_INCLUDED

#define DIELECTRICF0 half4(0.04, 0.04, 0.04, 1.0 - 0.04)

const float NON_ZERO = 6.103515625e-5;

struct LightingData {
    half3 direction;
    half3 color;
};

struct BRDFData {
    half3 diffuseColor, specularColor;
    half roughness;
    float3 normalWS, viewDirWS;
};

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

half4 PBRLighting(LightingData lightingData, BRDFData brdfData) {
    float3 halfDir = normalize(lightingData.direction + brdfData.viewDirWS);

    half ndotv = abs(dot(brdfData.normalWS, brdfData.viewDirWS));
    half ndotl = saturate(dot(brdfData.normalWS, lightingData.direction));
    half ndoth = saturate(dot(brdfData.normalWS, halfDir));
    half ldoth = saturate(dot(lightingData.direction, halfDir));

    half3 diffuseTerm = DisneyDiffuse(brdfData.roughness, brdfData.diffuseColor, ndotv, ndotl, ldoth) * ndotl;

    half roughness = max(brdfData.roughness * brdfData.roughness, 0.002);
    half3 F = Fresnel(brdfData.specularColor, ldoth);
    half G = SmithJointGGX(roughness, ndotl, ndotv);
    half D = GGX(roughness, ndoth);
    half3 specularTerm = (F * D * G) *PI;/// (4 * ndotl * ndotv);//
    specularTerm = max(0, specularTerm * ndotl);

    half3 color = diffuseTerm * lightingData.color + specularTerm * lightingData.color;
    return half4(color, 1);
}
#endif