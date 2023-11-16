Shader "URP Shader/Blur Texture" {
    Properties {
        _MainTex ("Texture", 2D) = "white" { }
        _Size ("Size", float) = 5
    }

    HLSLINCLUDE

    #pragma multi_compile_fragment _ _LINEAR_TO_SRGB_CONVERSION

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

    SAMPLER(sampler_BlitTexture);
    float4 _BlitTexture_TexelSize;
    float _Size;

    half4 BlurHorizontalPixel(float weight, float kernelx, float2 uv) {
        return SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_BlitTexture, uv + float2(_BlitTexture_TexelSize.x * kernelx * _Size, 0)) * weight;
    }

    half4 BlurHorizontal(Varyings input) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        float2 uv = input.texcoord;

        half4 color = half4(0, 0, 0, 1);
        color += BlurHorizontalPixel(0.05, -4.0, uv);
        color += BlurHorizontalPixel(0.09, -3.0, uv);
        color += BlurHorizontalPixel(0.12, -2.0, uv);
        color += BlurHorizontalPixel(0.15, -1.0, uv);
        color += BlurHorizontalPixel(0.18, 0.0, uv);
        color += BlurHorizontalPixel(0.15, +1.0, uv);
        color += BlurHorizontalPixel(0.12, +2.0, uv);
        color += BlurHorizontalPixel(0.09, +3.0, uv);
        color += BlurHorizontalPixel(0.05, +4.0, uv);

        #ifdef _LINEAR_TO_SRGB_CONVERSION
            color = LinearToSRGB(color);
        #endif

        return color;
    }

    half4 BlurVerticalPixel(float weight, float kernelx, float2 uv) {
        return SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_BlitTexture, uv + float2(0, _BlitTexture_TexelSize.y * kernelx * _Size)) * weight;
    }

    half4 BlurVertical(Varyings input) : SV_Target {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
        float2 uv = input.texcoord;

        half4 color = half4(0, 0, 0, 1);
        color += BlurVerticalPixel(0.05, -4.0, uv);
        color += BlurVerticalPixel(0.09, -3.0, uv);
        color += BlurVerticalPixel(0.12, -2.0, uv);
        color += BlurVerticalPixel(0.15, -1.0, uv);
        color += BlurVerticalPixel(0.18, 0.0, uv);
        color += BlurVerticalPixel(0.15, +1.0, uv);
        color += BlurVerticalPixel(0.12, +2.0, uv);
        color += BlurVerticalPixel(0.09, +3.0, uv);
        color += BlurVerticalPixel(0.05, +4.0, uv);

        #ifdef _LINEAR_TO_SRGB_CONVERSION
            color = LinearToSRGB(color);
        #endif

        return color;
    }

    ENDHLSL

    SubShader {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 100
        ZTest Always
        ZWrite Off
        Cull Off

        Pass {
            Name "Blur Horizontal"

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment BlurHorizontal

            ENDHLSL
        }

        Pass {
            Name "Blur Vertical"

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment BlurVertical

            ENDHLSL
        }
    }
}