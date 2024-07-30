#ifndef WATER_COLOR_INCLUDED
#define WATER_COLOR_INCLUDED

//#include "WorldSpaceDepth.hlsl"

sampler2D _CameraDepthTexture;

half4 _ShallowCollor, _DeepColor;
float _DepthRange;

half4 _FoamColor;
float _FoamIntensity, _FoamDistance;

half4 WaterColor(float4 screenPos, float2 uv, float4 positionCS, float3 positionWS) {

    float backgroundDepth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, screenPos), _ZBufferParams);
    float depthDifference = backgroundDepth - screenPos.z;
    
    //float depthDifference = WorldSpaceDepth(positionCS, positionWS);

    //float depth = saturate(depthDifference / _DepthRange);
    float depth = saturate(exp(depthDifference / _DepthRange));

    half4 color;
    color = lerp(_ShallowCollor, _DeepColor, depth);
    color.a *= saturate(depthDifference / _DepthRange);

    float foamOffset = tex2D(_FoamMap, uv * _FoamMap_ST.xy + _Time.x).x;
    float foamFactor = pow(saturate(_FoamIntensity * foamOffset -depthDifference) * 20, 20) * saturate(depthDifference / _FoamDistance);
    color = lerp(color, _FoamColor, foamFactor);

    return color;
}

half4 WaterColorVertexTransparent(half vertexAlpha) {
    half4 color = vertexAlpha;
    color.rgb = lerp(_ShallowCollor, _DeepColor, vertexAlpha);
    return color;
}

#endif