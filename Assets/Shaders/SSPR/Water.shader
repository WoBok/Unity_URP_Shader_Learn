Shader "Water/Water" {
    Properties {
        _DiffuseColor ("DiffuseColor", COLOR) = (1, 1, 1, 1)
        _NormalTex ("NormalTex", 2D) = "white" { }
        _WaveParams ("WavaParam", vector) = (0.04, 0.02, -0.02, -0.04)
        _NormalScale ("NormalScale", Range(0, 1)) = 0.3
        _LightDir ("LightDir", vector) = (0, 1, 0, 0)
        _WaterSpecular ("WaterSpecular", Range(0, 1)) = 0.8
        _WaterSmoothness ("WaterSmoothness", Range(0, 1)) = 0.8
        _SpecularColor ("SpecularColor", COLOR) = (1, 1, 1, 1)
        _RimPower ("RimPower", Range(0, 20)) = 8
        _Roughness ("Roughness", Range(0, 1)) = 0.25
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            Tags { "LightMode" = "MobileSSPR" }

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MobileSSPR
            
            #include "MobileSSPRInclude.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                half4 vertex : POSITION;
                half3 normal : NORMAL;
                half2 uv : TEXCOORD0;
                half4 tangent : TANGENT;
            };

            struct Varyings {
                half4 vertex : SV_POSITION;
                half3 worldPos : TEXCOORD0;
                half2 uv : TEXCOORD1;
                half4 TW0 : TEXCOORD2;
                half4 TW1 : TEXCOORD3;
                half4 TW2 : TEXCOORD4;
                half4 screenPos : TEXCOORD5;
            };
            
            CBUFFER_START(UnityPerMaterial)
            half4 _DiffuseColor;
            sampler2D _NormalTex;
            half4 _NormalTex_ST;
            half4 _WaveParams;
            half _NormalScale;
            half4 _LightDir;
            half _WaterSpecular;
            half _WaterSmoothness;
            half3 _SpecularColor;
            half _RimPower;
            half _Roughness;
            CBUFFER_END

            half3 BlendNormals(half3 n1, half3 n2) {
                return normalize(half3(n1.xy + n2.xy, n1.z * n2.z));
            }

            Varyings vert(Attributes IN) {

                Varyings OUT;
                
                OUT.vertex = TransformObjectToHClip(IN.vertex.xyz);

                OUT.worldPos = mul(unity_ObjectToWorld, IN.vertex).xyz;

                OUT.uv = IN.uv.xy * _NormalTex_ST.xy + _NormalTex_ST.zw;

                half3 worldNormal = normalize(mul(IN.normal, (float3x3)unity_WorldToObject));
                half3 worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, IN.tangent));
                half tangentSign = IN.tangent.w * unity_WorldTransformParams.w;
                half3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;

                OUT.TW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, OUT.worldPos.x);
                OUT.TW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, OUT.worldPos.y);
                OUT.TW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, OUT.worldPos.z);

                OUT.screenPos = ComputeScreenPos(OUT.vertex);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target {
                half2 panner1 = (_Time.y * _WaveParams.xy + IN.uv);
                half2 panner2 = (_Time.y * _WaveParams.zw + IN.uv);

                half3 worldNormal = BlendNormals(UnpackNormal(tex2D(_NormalTex, panner1)), UnpackNormal(tex2D(_NormalTex, panner2)));
                worldNormal = lerp(half3(0, 0, 1), worldNormal, _NormalScale);
                worldNormal = normalize(half3(dot(IN.TW0.xyz, worldNormal), dot(IN.TW1.xyz, worldNormal), dot(IN.TW2, worldNormal)));

                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.worldPos);
                half NdotV = saturate(dot(worldNormal, viewDir));
                half3 halfDir = normalize(_LightDir.xyz + viewDir);

                half4 diffuse = _DiffuseColor * NdotV * 0.5;
                half3 specular = _SpecularColor.rgb * _WaterSpecular * pow(max(0, dot(worldNormal, halfDir)), _WaterSmoothness * 2560);
                half3 rim = pow(1 - saturate(NdotV), _RimPower) * _SpecularColor * 0.2;

                half3 color = diffuse + specular + rim;

                //ªÒµ√∑¥…‰
                //================================================================
                ReflectionInput reflectionData;
                reflectionData.posWS = IN.worldPos;
                reflectionData.normalWS=worldNormal;
                reflectionData.screenPos = IN.screenPos;
                reflectionData.roughness = _Roughness;
                reflectionData.SSPR_Usage = 1;
                half3 resultReflection = GetResultReflection(reflectionData);
                //resultReflection += specular;
                //================================================================

                return half4(resultReflection * color, 1) ;
            }
            ENDHLSL
        }
    }
}