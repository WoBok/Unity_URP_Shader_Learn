Shader "ShaderLab Syntax/ShaderInclude"
{
    SubShader
    {
        Pass
        {
            HLSLPROGRAM
            #pragma vertex UnlitPassVertex
            #pragma fragment UnlitPassFragment
            #include "UnlitPass.hlsl"
            #include "UnlitPass.hlsl"
            ENDHLSL
        }
    }
}
