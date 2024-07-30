#ifndef WATER_LIGHTING_INCLUDED
#define WATER_LIGHTING_INCLUDED

half4 _FresnelColor;
float _FresnelPower, _FresnelIntensity;

half3 GetFresnelColor(InputData inputData) {
    return pow((1 - saturate(dot(inputData.normalWS, inputData.viewDirectionWS))), _FresnelPower) * _FresnelColor.rgb * _FresnelIntensity;
}

half3 GetAdditionalLightColor(InputData inputData) {
    half3 lightColor = 0;

    uint pixelLightCount = GetAdditionalLightsCount();
    LIGHT_LOOP_BEGIN(pixelLightCount)
    Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
    #ifdef _LIGHT_LAYERS
        uint meshRenderingLayers = GetMeshRenderingLayer();
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
    #endif
    half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
    half3 lightDiffuseColor = LightingLambert(attenuatedLightColor, light.direction, inputData.normalWS);
    lightColor += lightDiffuseColor;
    LIGHT_LOOP_END

    return lightColor;
}
#endif