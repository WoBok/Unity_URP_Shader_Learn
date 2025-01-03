#ifndef WATER_FORWARD_PASS_INCLUDED
#define WATER_FORWARD_PASS_INCLUDED

#include "WaterInput.hlsl"
#include "GerstnerWave.hlsl"
#include "WaterSurface.hlsl"

Varyings Vertex(Attributes input) {
    Varyings output;
    
    float3 tangent = float3(1, 0, 0);
    float3 binormal = float3(0, 0, 1);
    float3 position = input.positionOS.xyz;

    GERSTNER_WAVE(_Wave1) GERSTNER_WAVE(_Wave2) GERSTNER_WAVE(_Wave3) GERSTNER_WAVE(_Wave4)
    GERSTNER_WAVE(_Wave5) GERSTNER_WAVE(_Wave6)GERSTNER_WAVE(_Wave7) GERSTNER_WAVE(_Wave8)
    GERSTNER_WAVE(_Wave9) GERSTNER_WAVE(_Wave10) GERSTNER_WAVE(_Wave11) GERSTNER_WAVE(_Wave12)

    float3 normal = normalize(cross(binormal, tangent));

    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    output.normalWS = TransformObjectToWorldNormal(normal);
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    output.positionWS = positionWS;

    real3 tangentWS = real3(TransformObjectToWorldDir(input.tangentOS.xyz));
    real sign = input.tangentOS.w * (unity_WorldTransformParams.w >= 0.0 ? 1.0 : - 1.0);
    output.tangentWS = half4(tangentWS.xyz, sign);

    output.vertexAlpha = input.color.a;

    output.uv = input.texcoord;

    output.screenPos = ComputeScreenPos(output.positionCS);
    output.screenPos.z = -TransformWorldToView(TransformObjectToWorld(input.positionOS)).z;

    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    return output;
}

#include "Tessellation.hlsl"

half4 Fragment(Varyings input) : SV_Target {
    return Surface(input);
}
#endif