Shader "URP Shader/ContourLines" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        [HDR]_BaseColor ("Color", Color) = (1, 1, 1, 1)

        [HDR]_ContourColor ("LineColor", Color) = (1, 1, 1, 1)
        _ContourLineRate ("ContourLineRate", Range(0, 1)) = 1//等高线占HeightOffset的比例
        _HeightOffset ("HeightOffset", Float) = 10//高度分段
        _GroundHight ("GroundHight", Float) = 0

        _ApertureMap ("ApertureMap", 2D) = "white" { }
        [HDR]_ApertureColor ("_ApertureColor", Color) = (1, 1, 1, 1)
        _Center ("Center", Vector) = (0, 0, 0, 0)
        _CenterFactor ("CenterFactor", float) = 200
        _RadialScale ("RadialScale", Float) = 0
        _LengthScale ("LengthScale", Float) = 0
        _USpeed ("USpeed", Float) = -0.5
        _VSpeed ("VSpeed", Float) = 0
        _ApertureOffset ("_ApertureOffset", Vector) = (0, 0, 0, 0)
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
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
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float2 apertureUV : TEXCOORD3;
                float4 positionCS : SV_POSITION;
                float4 positionOS : TEXCOORD4;
            };
            
            sampler2D _BaseMap;
            sampler2D _ApertureMap;
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            float4 _ApertureMap_ST;
            half4 _BaseColor;

            half4 _ContourColor;
            float _HeightOffset;
            float _ContourLineRate;
            float _GroundHight;
            float4 _Center;
            float _CenterFactor;
            float _RadialScale;
            float _LengthScale;
            float _USpeed;
            float _VSpeed;
            half4 _ApertureColor;
            float4 _ApertureOffset;
            CBUFFER_END

            void GetPolarCoordinatesUV(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out) {
                float2 delta = UV - Center;
                float radius = length(delta) * 2 * RadialScale;
                float angle = atan2(delta.x, delta.y) * 1.0 / 6.28 * LengthScale;
                Out = float2(radius, angle);
            }

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);

                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                
                output.positionOS = input.positionOS;

                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));

                output.uv = input.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;

                output.apertureUV = input.texcoord.xy * _ApertureMap_ST.xy + _ApertureMap_ST.zw;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                half4 albedo = tex2D(_BaseMap, input.uv) * _BaseColor;
                half4 diffuse = albedo * (dot(input.normalWS, normalize(_MainLightPosition.xyz)) * 0.5 + 0.5);
                
                float2 apertureUV ;
                float center = input.positionOS.z * _CenterFactor / 200;
                GetPolarCoordinatesUV(input.apertureUV.xy, center.xx + _ApertureOffset, _RadialScale, _LengthScale, apertureUV);
                float2 speed = float2(_USpeed, _VSpeed);
                speed *= _Time.y;
                half4 apertureColor = tex2D(_ApertureMap, apertureUV + speed);
                apertureColor = apertureColor * _ApertureColor;

                //half tempRate = (input.positionOS.z + _GroundHight) / _HeightOffset;
                //half fract = tempRate - floor(tempRate);
                //half funRes = 1 - step(fract, 1 - _ContourLineRate);
                //half contourColor = _ContourColor * funRes ;

                half contourLine = (input.positionOS.z + _GroundHight) / _HeightOffset;
                contourLine = frac(contourLine);
                contourLine = abs(contourLine);
                contourLine = step(_ContourLineRate, contourLine);
                half4 contourColor = contourLine * _ContourColor;

                half4 fincolor = contourColor * apertureColor + diffuse ;

                return contourColor ;
            }
            ENDHLSL
        }
    }
}