Shader "Demo/Cloud/Cloud" {
    Properties {
        _ShapeTex ("Albedo", 2D) = "white" { }
        _Threshold ("Threshold", Range(0, 1)) = 1
        _BillboardScale ("Billboard Scale", Range(0, 5)) = 2.5
        _ShadingOffset ("Shading Offset", Range(0, 1)) = 0.35
        _GradientTexture ("Gradient Texture", 2D) = "white" { }
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct Varyings {
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD2;
            };
            
            sampler2D _ShapeTex;
            sampler2D _GradientTexture;
            CBUFFER_START(UnityPerMaterial)
            float4 _ShapeTex_ST;
            float _Threshold;
            float _BillboardScale;
            float _ShadingOffset;
            CBUFFER_END

            //float4x4 GetCameraPositionMatrix() {
            //    float3 _Camera_Position = _WorldSpaceCameraPos;
            //    float3 _Object_Position = SHADERGRAPH_OBJECT_POSITION;
            //    float3 dirWS = _Object_Position - _Camera_Position;
            //    float3 dirOS = TransformWorldToObject(dirWS);
            //    dirOS = normalize(dirOS);
            //    float3 crossValue = cross(float3(0, 1, 0), dirOS);
            //    float3 crossValue2 = cross(dirOS, crossValue);
            //    return float4x4(crossValue, crossValue2, dirOS, float4(0, 0, 0, 1));
            //}

            float4 Remap(float4 In, float2 InMinMax, float2 OutMinMax) {
                return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            half NDotL(half3 Normal, half3 LightDirection,   half ShadingOffset) {
                const half nDotL = dot(Normal, LightDirection) * 0.5 + 0.5;
                const half angleDiff = saturate(nDotL * (1-ShadingOffset));
                return angleDiff;
            }

            float4 VaryPosition(float4 uv, float4 positionOS) {
                float4 remapUV = Remap(uv, float2(0, 1), float2(-1, 1));
                float4 viewUV = mul( UNITY_MATRIX_V,remapUV);
                float4 modelUV = mul( UNITY_MATRIX_M,viewUV);

                //float3 _Object_Scale = float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                //length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                //length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z)));

                //float4 scaledModelUV = mul(modelUV, _Object_Scale);

                modelUV *= _BillboardScale;
                modelUV = positionOS + modelUV;
                
                //scaledModelUV = normalize(scaledModelUV);
                //scaledModelUV *= _BillboardScale;
                //scaledModelUV = positionOS + scaledModelUV;

                return modelUV;
            }


            Varyings Vertex(Attributes input) {

                Varyings output;
                
                float4 variedPosition = VaryPosition(input.texcoord, input.positionOS);

                output.positionCS = mul(UNITY_MATRIX_MVP, variedPosition);
                
                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));

                output.uv = input.texcoord.xy * _ShapeTex_ST.xy + _ShapeTex_ST.zw;

                output.positionWS = TransformObjectToWorld(input.positionOS);

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {

                half4 alphaTest = tex2D(_ShapeTex, input.uv).a;

                half4 diffuse = (dot(input.normalWS, normalize(_MainLightPosition.xyz)) * 0.5 + 0.5);

                half4 color = diffuse;

                clip(alphaTest - _Threshold);

                color.a = alphaTest;

                #if SHADOWS_SCREEN
                    half4 clipPos = TransformWorldToHClip(input.positionWS);
                    half4 shadowCoord = ComputeScreenPos(clipPos);
                #else
                    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                #endif
                Light light = GetMainLight(shadowCoord);

                float shading = NDotL(input.normalWS, light.direction,  _ShadingOffset);

                float4 gradientColor = tex2D(_GradientTexture, float2(shading, 0.5));
                gradientColor.a=alphaTest;
                return  gradientColor;
            }
            ENDHLSL
        }
    }
}