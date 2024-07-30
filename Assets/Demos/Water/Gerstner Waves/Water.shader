Shader "URP Shader/Water" {
    Properties {
        [Header(PBR)]
        [Space(5)]
        _Smoothness ("Smoothness", Range(0, 1)) = 0
        _Metallic ("Metallic", Range(0, 1)) = 0

        [Header(Color)]
        [Space(5)]
        _ShallowCollor ("Shallow Color", Color) = (1, 1, 1, 1)
        _DeepColor ("Deep Color", Color) = (1, 1, 1, 1)
        _DepthRange ("Depth Range", Float) = 1

        [Header(Normal)]
        [Space(5)]
        [Toggle]_NormalSwitch ("Normal Switch", Float) = 0
        _MainNormalMap ("Main Normal Map", 2D) = "white" { }
        _SecondNormalMap ("Second Normal Map", 2D) = "white" { }
        _NormalScale ("Normal Scale", Float) = 0.2
        _NormalSpeed ("Normal Speed", Float) = 1

        [Header(Foam)]
        [Space(5)]
        _FoamMap ("Foam Map", 2D) = "white" { }
        _FoamColor ("Foam Color", Color) = (1, 1, 1, 1)
        _FoamIntensity ("Foam Intensity", Float) = 1
        _FoamDistance ("Foam Distance", Float) = 0.1

        [Header(Fresnel)]
        [Space(5)]
        _FresnelColor ("Fresnel Color", Color) = (1, 1, 1, 0)
        _FresnelPower ("Fresnel Power", Range(0, 100)) = 3
        _FresnelIntensity ("Frensnel Intensity", Range(0, 1)) = 1

        [Header(Wave)]
        [Space(5)]
        _WaveSpeed ("Wave Speed", Float) = 1
        _Wave1 ("Wave 1 Wavelength, Steepness, Direction", Vector) = (10, 0.5, 1, 0)
        _Wave2 ("Wave 2 Wavelength, Steepness, Direction", Vector) = (20, 0.25, 0, 1)
        _Wave3 ("Wave 3 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave4 ("Wave 4 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave5 ("Wave 5 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave6 ("Wave 6 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave7 ("Wave 7 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave8 ("Wave 8 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave9 ("Wave 9 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave10 ("Wave 10 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave11 ("Wave 11 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)
        _Wave12 ("Wave 12 Wavelength, Steepness, Direction", Vector) = (10, 0.15, 1, 1)

        [Header(Vertex Transparent)]
        [Space(5)]
        [Toggle]_VertexTransparent ("Vertex Transparent", Float) = 0

        [Header(Tessellation)]
        [Space(5)]
        _TessellationUniform ("Tessellation Uniform", Range(1, 64)) = 1
        _TessellationEdgeLength ("Tessellation Edge Length", Range(1, 100)) = 50
        [Toggle]_Tessellation_Edge ("Tessellation Edge", Float) = 1

        [Enum(UnityEngine.Rendering.CullMode)]_Cull ("Cull", Float) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull[_Cull]

            HLSLPROGRAM

            #pragma vertex  TessellationVertexProgram
            #pragma hull  HullProgram
            #pragma domain  DomainProgram
            #pragma fragment Fragment

            #pragma shader_feature _TESSELLATION_EDGE_ON
            #pragma shader_feature _NORMALSWITCH_ON
            #pragma shader_feature _VERTEXTRANSPARENT_ON

            #pragma multi_compile  _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ SHADOWS_SHADOWMASK

            #include "WaterForwardPass.hlsl"
            
            ENDHLSL
        }
    }
}