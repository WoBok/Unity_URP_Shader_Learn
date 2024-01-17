Shader "URP Shader/EdgeDetection" {
    Properties {
        _BaseMap ("Albedo", 2D) = "white" { }
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _EdgeColor ("Edge Color", Color) = (0, 0, 0, 0)
        _BackgroundColor ("Background Color", color) = (1, 1, 1, 1)
        _EdgeOnly ("EdgeOnly", Range(0, 1)) = 0
        _Radius ("Radius", float) = 1
        _Speed ("Speed", float) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
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
                float3 normalWS : TEXCOORD0;
                float3 positionOS : TEXCOORD1;
                float2 uv[9] : TEXCOORD2;
                float4 positionCS : SV_POSITION;
            };
            
            sampler2D _BaseMap;
            CBUFFER_START(UnityPerMaterial)
            half4 _BaseMap_TexelSize;
            half4 _BaseColor;
            half4 _EdgeColor;
            half4 _BackgroundColor;
            half _EdgeOnly;
            half _Radius;
            half _Speed;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                output.positionOS = input.positionOS;

                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);
                
                output.normalWS = normalize(mul(input.normalOS, (float3x3)unity_WorldToObject));

                half2 uv = input.texcoord;
                output.uv[0] = uv + _BaseMap_TexelSize.xy * half2(-1, -1);
                output.uv[1] = uv + _BaseMap_TexelSize.xy * half2(0, -1);
                output.uv[2] = uv + _BaseMap_TexelSize.xy * half2(1, -1);
                output.uv[3] = uv + _BaseMap_TexelSize.xy * half2(-1, 0);
                output.uv[4] = uv + _BaseMap_TexelSize.xy * half2(0, 0);
                output.uv[5] = uv + _BaseMap_TexelSize.xy * half2(1, 0);
                output.uv[6] = uv + _BaseMap_TexelSize.xy * half2(-1, 1);
                output.uv[7] = uv + _BaseMap_TexelSize.xy * half2(0, 1);
                output.uv[8] = uv + _BaseMap_TexelSize.xy * half2(1, 1);

                return output;
            }

            half Luminance(half4 color) {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            half Sobel(Varyings input) {

                const half Gx[9] = {
                    - 1, -2, -1,
                    0, 0, 0,
                    1, 2, 1
                };
                const half Gy[9] = {
                    - 1, 0, 1,
                    - 2, 0, 2,
                    - 1, 0, 1
                };

                half texLuminance;
                half edgeX = 0;
                half edgeY = 0;
                for (int i = 0; i < 9; i++) {
                    texLuminance = Luminance(tex2D(_BaseMap, input.uv[i]));
                    edgeX += texLuminance * Gx[i];
                    edgeY += texLuminance * Gy[i];
                }

                half edge = 1 - abs(edgeX) - abs(edgeY);

                return edge;
            }

            half4 Fragment(Varyings input) : SV_Target {

                half4 albedo = tex2D(_BaseMap, input.uv[4]);

                half4 diffuse = albedo * (dot(input.normalWS, normalize(_MainLightPosition.xyz)) * 0.5 + 0.5);

                half4 color = diffuse * _BaseColor;

                float inner = step(sqrt(input.positionOS.x * input.positionOS.x + input.positionOS.y * input.positionOS.y), _Radius * frac(_Time.x*_Time.x * _Speed));
                half edge = Sobel(input) * (inner);
                half4 withEdgeColor = lerp(_EdgeColor, color, edge);
                withEdgeColor = lerp(withEdgeColor, color, 1 - inner);
                half4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
                onlyEdgeColor = lerp(onlyEdgeColor, color, 1 - inner);
                half4 finalEdgeColor = lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);

                return finalEdgeColor;
            }
            ENDHLSL
        }
    }
}