#ifndef LEAVESTRS_INCLUDED
#define LEAVESTRS_INCLUDED

StructuredBuffer<float4x4> trsBuffer;

void ProcessTRSMatrix() {
    #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
        unity_ObjectToWorld = trsBuffer[unity_InstanceID];
    #endif
}

void PassThrough_float(in float3 In, out float3 Out) {
    Out = In;
}

#endif