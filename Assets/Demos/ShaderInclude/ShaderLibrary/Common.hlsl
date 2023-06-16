#ifndef CUSTOM_COMMON_INCLUDED
#define CUSTOM_COMMON_INCLUDED
#include "UnityInput.hlsl"
float4 TransformObjectToWorld(float3 positionOS) {
    return mul(unity_ObjectToWorld, float4(positionOS, 1));
}
float4 TransformWorldToHClip(float3 positionWS) {
    return mul(unity_MatrixVP, float4(positionWS, 1));
}
#endif