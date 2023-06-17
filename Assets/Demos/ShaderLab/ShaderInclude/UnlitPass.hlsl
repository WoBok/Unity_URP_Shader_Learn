#ifndef CUSTOM_UNLIT_PASS_INCLUDED
#define CUSTOM_UNLIT_PASS_INCLUDED
#include "ShaderLibrary/Common.hlsl"
float4 UnlitPassVertex(float3 positionOS : POSITION) : SV_POSITION {
    //return float4(positionOS,1);
    float4 positionWS=TransformObjectToWorld(positionOS);
    return TransformWorldToHClip(positionWS);
}
half4 UnlitPassFragment() : SV_TARGET {
    return half4(1,1,0,1);
}
#endif