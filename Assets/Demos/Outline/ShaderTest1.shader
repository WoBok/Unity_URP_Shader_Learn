Shader "Demo/Outline/OutLine_View1" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 0)
        _Outline ("Outline", float) = 1
        _Factor ("Factor", float) = 1
        _Power ("Power", float) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        //Pass {
        //    Tags { "LightMode" = "SRPDefaultUnlit" }

        //    Stencil {
        //        Ref 1
        //        Comp Always
        //        Pass Replace
        //    }
        //    HLSLPROGRAM

        //    #pragma vertex Vertex
        //    #pragma fragment Fragment

        //    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        //    struct Attributes {
        //        float4 positionOS : POSITION;
        //        float2 texcoord : TEXCOORD0;
        //    };

        //    struct Varyings {
        //        float2 uv : TEXCOORD0;
        //        float4 positionCS : SV_POSITION;
        //    };
        
        //    sampler2D _BaseMap;
        //    CBUFFER_START(UnityPerMaterial)
        //    float4 _BaseMap_ST;
        //    half4 _BaseColor;
        //    CBUFFER_END

        //    Varyings Vertex(Attributes input) {

        //        Varyings output;
        
        //        output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

        //        output.uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;

        //        return output;
        //    }

        //    half4 Fragment(Varyings input) : SV_Target {

        //        half4 albedo = tex2D(_BaseMap, input.uv);

        //        return albedo * _BaseColor;
        //    }
        //    ENDHLSL
        //}

        Pass {
            Tags { "LightMode" = "UniversalForward" }
            //Blend SrcAlpha OneMinusSrcAlpha
            //Stencil {
            //    Ref 1
            //    Comp NotEqual
            //}
            Cull Back
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                // float factor : TEXTCORD1;
                float3 normalWS : TEXTCORD1;
                float3 viewDirWS : TEXTCORD2;
            };

            sampler2D _BaseMap;
            CBUFFER_START(UnityPerMaterial)
            half4 _OutlineColor;
            half _Outline;
            half _Factor;
            half _A;
            half _B;
            half _Power;
            float4 _BaseMap_ST;
            half4 _BaseColor;
            CBUFFER_END

            Varyings Vertex(Attributes input) {
                Varyings output;
                output. viewDirWS = normalize(_WorldSpaceCameraPos.xyz - TransformObjectToWorld(input.positionOS.xyz));
                output. normalWS = normalize(mul(input.positionOS, UNITY_MATRIX_M));
                //output.factor = step(_Outline, pow(dot(normalWS, viewDirWS), _Factor));
                //output.color = factor * _OutlineColor;
                
                //output.color = pow((1.0 - saturate(dot(normalWS, viewDirWS))), _Power) * _OutlineColor;
                //input.positionOS.xyz += normalize(input.normalOS).xyz * _Outline*factor*_Factor;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {
                half4 albedo = tex2D(_BaseMap, input.uv);
                float factor = step(_Outline, dot(input.normalWS, input.viewDirWS));
                return albedo * _BaseColor * factor;
            }
            ENDHLSL
        }
    }
}