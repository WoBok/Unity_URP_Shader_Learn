#ifndef PBR_LIGHTING_INCLUDED
#define PBR_LIGHTING_INCLUDED

half3 FresnelSchlick(half3 f0, float3 v, float3 h) {
    half VoH = saturate(dot(v, h));
    return f0 + (1 - f0) * pow((1 - VoH), 5);
}

#endif