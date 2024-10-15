#ifndef PBR_FORWARD_PASS_INCLUDED
#define PBR_FORWARD_PASS_INCLUDED

#include "PBRLighting.hlsl"
#include "PBRInput.hlsl"

Varyings Vertex(Attributes input) {

    Varyings output = (Varyings)0;
    
    output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);
    output.positionWS = mul(UNITY_MATRIX_M, input.positionOS).xyz;

    output.normalWS = normalize(mul(input.normalOS, (float3x3)UNITY_MATRIX_I_M));
    #ifdef _NORMALSWITCH_ON
        output.tangentWS = normalize(mul((float3x3)UNITY_MATRIX_M, input.tangentOS.xyz));
        half sign = unity_WorldTransformParams.w >= 0.0 ? 1.0 : - 1.0;
        output.bitangentWS = cross(output.normalWS, output.tangentWS) * input.tangentOS.w * sign;
    #endif

    output.uv = input.texcoord.xy * _AlbedoMap_ST.xy + _AlbedoMap_ST.zw;

    return output;
}

half4 Fragment(Varyings input) : SV_Target {
    LightingData lightingData;
    InitializeLightingData(lightingData);

    BRDFData brdfData;
    InitializeBRDFData(input, brdfData);

    return PBRLighting(lightingData, brdfData);
}

#endif