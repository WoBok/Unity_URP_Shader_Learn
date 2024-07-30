#ifndef WATER_NORMAL_INCLUDED
#define WATER_NORMAL_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"

TEXTURE2D(_MainNormalMap);
SAMPLER(sampler_MainNormalMap);
TEXTURE2D(_SecondNormalMap);
SAMPLER(sampler_SecondNormalMap);

float4 _MainNormalMap_ST, _SecondNormalMap_ST;
float _NormalScale, _NormalSpeed;

float3 BlendNormals(float3 n1, float3 n2) {
    return normalize(float3(n1.xy + n2.xy, n1.z * n2.z));
}

half3 SampleNormal(float2 uv, TEXTURE2D_PARAM(bumpMap, sampler_MainNormal), half scale = half(1.0)) {
    half4 n = SAMPLE_TEXTURE2D(bumpMap, sampler_MainNormal, uv);
    #if BUMP_SCALE_NOT_SUPPORTED
        return UnpackNormal(n);
    #else
        return UnpackNormalScale(n, scale);
    #endif
}

float3 NormalStrength(float3 n, float strength) {
    return float3(n.rg * strength, lerp(1, n.b, saturate(strength)));
}

float3 GetNormal(float3 normalWS, float2 uv) {
    float speed = _NormalSpeed / 100;
    float uv1Speed = _Time.y * - 2 * speed;
    float2 uv1 = uv * _MainNormalMap_ST.xy + float2(uv1Speed, uv1Speed);
    float uv2Speed = _Time.y * speed;
    float2 uv2 = uv * _SecondNormalMap_ST.xy + float2(uv2Speed, uv2Speed);
    float3 normal1 = SampleNormal(uv1, TEXTURE2D_ARGS(_MainNormalMap, sampler_MainNormalMap));
    float3 normal2 = SampleNormal(uv2, TEXTURE2D_ARGS(_SecondNormalMap, sampler_SecondNormalMap));
    float3 normal = normal1 + normal2;
    normal += normalWS ;
    return NormalStrength(normal, _NormalScale);
}
#endif