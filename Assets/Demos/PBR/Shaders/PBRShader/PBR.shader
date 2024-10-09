Shader "PBR Shader/PBR" {
    Properties {
        _AlbedoMap ("Base Map", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)

        [Header(Specular)]
        [Toggle]_MetallicSwitch ("Metallic Switch", Int) = 0
        _MetallicMap ("Metallic Map", 2D) = "white" { }
        _Metallic ("Metallic", Range(0, 1)) = 0
        _MetallicScale ("Metallic Scale", Range(0, 1)) = 1
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5

        [Header(Normal)]
        [Toggle]_NormalSwitch ("Normal Switch", Int) = 0
        _NormalMap ("Normal Map", 2D) = "white" { }
        _NormalScale ("Normal Scale", Float) = 1
        _OcclusionMap ("Occlusion Map", 2D) = "white" { }
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma shader_feature_local _NORMALSWITCH_ON
            #pragma shader_feature_local _METALLICSWITCH_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "PBRForwardPass.hlsl"

            ENDHLSL
        }
    }
}