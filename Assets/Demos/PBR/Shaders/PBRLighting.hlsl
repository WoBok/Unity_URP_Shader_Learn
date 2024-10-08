#ifndef PBR_LIGHTING_INCLUDED
#define PBR_LIGHTING_INCLUDED

#define DIELECTRICF0 half4(0.04, 0.04, 0.04, 1.0 - 0.04)

const float PI = 3. 141592653589793
const float NON_ZERO = 6.103515625e-5

struct BRDFData {
    half3 diffuseColor;
    half3 specularColor;
    half smoothness;
    float3 normalWS;
    float3 viewDirWS;
};

float3 SafeNormalize(float3 v) {
    return v * rsqrt(max(NON_ZERO, dot(v, v)));
}

half3 DisneyDiffuse(half roughness, half3 diffuseAlbedo, half ndotv, half ndotl, half ldoth) {
    half fd90 = 0.5 + 2 * roughness * ldoth * ldoth;

    half lightScatter = 1 + (fd90 - 1) * pow(1 - ndotl, 5);
    half viewScatter = 1 + (fd90 - 1) * pow(1 - ndotv, 5);

    diffuseAlbedo /= PI;

    return diffuseAlbedo * lightScatter * viewScatter;
}

half3 Fresnel(half3 f0, half vdoth) {
    return f0 + (1 - f0) * pow((1 - vdoth), 5);
}

float GGX(float roughness, float ndoth) {
    float a2 = roughness * roughness;
    float d = (ndoth * a2 - ndoth) * ndoth + 1;
    return a2 / max(PI * d * d, NON_ZERO);
}

float SmithJointGGX(float roughness, float ndotl, float ndotv) {
    half a2 = roughness * roughness;

    half lambdaV = ndotl * sqrt((-ndotv * a2 + ndotv) * ndotv + a2);
    half lambdaL = ndotv * sqrt((-ndotl * a2 + ndotl) * ndotl + a2);

    return 1 / (2 * max(NON_ZERO, lambdaV + lambdaL));
}

half4 PBRLighting(BRDFData brdfData) {

}
#endif