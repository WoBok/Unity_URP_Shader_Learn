Shader "Water/Water" {
    Properties {
        _NoiseTex ("NoiseTex", 2D) = "white" { }
        _ShalowColor ("ShalowColor", Color) = (1, 1, 1, 1)
        _DeepColor ("DeepColor", Color) = (1, 1, 1, 1)
        _NormalTex ("NormalTex", 2D) = "white" { }
        _WaveParams ("WavaParam", vector) = (0.04, 0.02, -0.02, -0.04)
        _NormalScale ("NormalScale", Range(0, 1)) = 0.3
        _LightDir ("LightDir", vector) = (0, 1, 0, 0)
        _WaterSpecular ("WaterSpecular", Range(0, 1)) = 0.8
        _WaterSmoothness ("WaterSmoothness", Range(0, 1)) = 0.8
        _SpecularColor ("SpecularColor", COLOR) = (1, 1, 1, 1)
        _RimPower ("RimPower", Range(0, 20)) = 8
        _FoamDepth ("FoamDepth", Range(-2, 10)) = 0.5
        _FoamOffset ("FoamOffset", vector) = (-0.01, 0.01, 2, 0.01)
        _FoamFactor ("FoamFactor", Range(0, 10)) = 0.2
        _FoamColor ("FoamColor", COLOR) = (1, 1, 1, 1)
        _WaterWave ("WaterWave", Range(0, 0.1)) = 0.02
        _DetailColor ("DetailColor", COLOR) = (1, 1, 1, 1)
        _Roughness ("Roughness", Range(0, 1)) = 0.25
        _Reflection ("Reflection", Range(0, 1)) = 0.5
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            Tags { "LightMode" = "MobileSSPR" }

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "MobileSSPRInclude.hlsl"
            #pragma multi_compile _ _MobileSSPR
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
            };

            struct Varyings {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float4 TW0 : TEXCOORD2;
                float4 TW1 : TEXCOORD3;
                float4 TW2 : TEXCOORD4;
                float4 screenPos : TEXCOORD5;
            };
            
            CBUFFER_START(UnityPerMaterial)
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            half4 _ShalowColor;
            half4 _DeepColor;
            sampler2D _NormalTex;
            half4 _WaveParams;
            float _NormalScale;
            float4 _LightDir;
            float _WaterSpecular;
            float _WaterSmoothness;
            half3 _SpecularColor;
            half _RimPower;
            sampler2D _CameraDepthTexture;
            half _FoamDepth;
            half4 _FoamOffset;
            half _FoamFactor;
            half4 _FoamColor;
            half _WaterWave;
            half4 _DetailColor;
            half _Roughness;
            half _Reflection;
            CBUFFER_END

            half3 BlendNormals(half3 n1, half3 n2) {
                return normalize(half3(n1.xy + n2.xy, n1.z * n2.z));
            }

            Varyings vert(Attributes IN) {

                Varyings OUT;
                
                OUT.vertex = TransformObjectToHClip(IN.vertex.xyz);

                OUT.worldPos = mul(unity_ObjectToWorld, IN.vertex).xyz;

                OUT.uv = IN.uv.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;

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
            float LinearEyeDepth(float z) {
                return 1.0 / (_ZBufferParams.z * z + _ZBufferParams.w);
            }
            half4 frag(Varyings IN) : SV_Target {

                half3 water = tex2D(_NoiseTex, IN.uv / _NoiseTex_ST.xy);
                half4 diffuse = lerp(_ShalowColor, _DeepColor, water.r);
                
                half2 panner1 = (_Time.y * _WaveParams.xy + IN.uv);
                half2 panner2 = (_Time.y * _WaveParams.zw + IN.uv);

                float3 worldNormal = BlendNormals(UnpackNormal(tex2D(_NormalTex, panner1)), UnpackNormal(tex2D(_NormalTex, panner2)));
                worldNormal = lerp(half3(0, 0, 1), worldNormal, _NormalScale);
                worldNormal = normalize(half3(dot(IN.TW0.xyz, worldNormal), dot(IN.TW1.xyz, worldNormal), dot(IN.TW2, worldNormal)));

                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.worldPos);
                float NdotV = saturate(dot(worldNormal, viewDir));


                half3 halfDir = normalize(_LightDir.xyz + viewDir);
                half3 specular = _SpecularColor.rgb * _WaterSpecular * pow(max(0, dot(worldNormal, halfDir)), _WaterSmoothness * 2560);

                half3 rim = pow(1 - saturate(NdotV), _RimPower) * _SpecularColor * 0.2;

                half4 screenPos = float4(IN.screenPos.xyz, IN.screenPos.w);
                half eyeDepth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, screenPos).r);
                half eyeDepthSubScreenPos = abs(eyeDepth - screenPos.w);
                half depthMask = 1 - eyeDepthSubScreenPos + _FoamDepth;


                half3 foam1 = tex2D(_NoiseTex, IN.uv + worldNormal.xy * _FoamOffset.w);
                half3 foam2 = tex2D(_NoiseTex, _Time.y * _FoamOffset.xy + IN.uv + worldNormal.xy * _FoamOffset.w);

                half a = foam1.y;
                half b = foam2.y;
                half c = water.y;

                float temp_output = (saturate((a + b) * depthMask * c - _FoamFactor));
                diffuse = lerp(diffuse, _FoamColor * _FoamOffset.z, temp_output);
                
                diffuse *= NdotV * 0.5;

                half2 detailpanner = (IN.uv .xy / _NoiseTex_ST.xy + worldNormal.xy * _WaterWave);
                half4 detail = tex2D(_NoiseTex, detailpanner).b * _DetailColor;

                diffuse.rgb += diffuse.rgb * detail.rgb * 0.5;

                half3 color = diffuse + specular + rim;


                //================================================================
                ReflectionInput reflectionData;
                reflectionData.posWS = IN.worldPos;
                reflectionData.screenPos = IN.screenPos;
                reflectionData.roughness = _Roughness;
                reflectionData.SSPR_Usage = 1;
                
                half3 resultReflection = GetResultReflection(reflectionData);
                half3 finalRGB = lerp(color, resultReflection, _Reflection);
                //================================================================

                return float4(resultReflection+color, 1) ;
            }
            ENDHLSL
        }
    }
}