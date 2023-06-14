Shader "Water/Water_Reflection_Normal_Depth" {
    Properties {
        _DiffuseColor ("DiffuseColor", COLOR) = (1, 1, 1, 1)
        _NormalTex ("NormalTex", 2D) = "white" { }
        _NormalTex2 ("NormalTex2", 2D) = "white" { }
        _NormalTiling ("NormalTiling", float) = 1
        _NormalTiling2 ("NormalTiling2", float) = 1
        _ReflectionNormalTex ("ReflectionNormalTex", 2D) = "white" { }
        _WaveSpeed ("WaveSpeen", float) = 1
        _WaveParams ("WavaParam", vector) = (0.04, 0.02, -0.02, -0.04)
        _ReflectionParams ("ReflectionParams", vector) = (0.02, 0.01, -0.01, -0.02)
        _NormalScale ("NormalScale", Range(0, 1)) = 0.3
        _ReflectionNormalScale ("ReflectionNormalScale", Range(0, 1)) = 0.2
        _LightDir ("LightDir", vector) = (0, 1, 0, 0)
        _WaterSpecular ("WaterSpecular", Range(0, 1)) = 0.8
        _WaterSmoothness ("WaterSmoothness", Range(0, 1)) = 0.8
        _SpecularColor ("SpecularColor", COLOR) = (1, 1, 1, 1)
        _RimPower ("RimPower", Range(0, 20)) = 8
        _Roughness ("Roughness", Range(0, 1)) = 0.25
        _ReflectionIntensity ("_ReflectionIntensity", Range(0, 1)) = 0.3
        /******************************************************************************/
        _Opacity ("Opacity", Range(0, 1)) = 1
        _OpacityMin ("OpacityMin", Range(0, 1)) = 0.5
        _OpacityFalloff ("_OpacityFalloff", float) = 3
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }

        Pass {
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

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
                half3 worldNormal : NORMAL;
                half2 uvRefection : TEXCOORD6;
                half4 screenPos_Depth : TEXCOORD7;
            };

            TEXTURE2D(_MobileSSPR_ColorRT);
            sampler LinearClampSampler;
            sampler2D _NormalTex;
            sampler2D _NormalTex2;
            sampler2D _ReflectionNormalTex;
            sampler2D _ReflectionRT;
            CBUFFER_START(UnityPerMaterial)
            half4 _DiffuseColor;
            half _NormalTiling;
            half _NormalTiling2;
            half4 _NormalTex_ST;
            half4 _ReflectionNormalTex_ST;
            half _WaveSpeed;
            half4 _WaveParams;
            half4 _ReflectionParams;
            half _NormalScale;
            half _ReflectionNormalScale;
            half4 _LightDir;
            half _WaterSpecular;
            half _WaterSmoothness;
            half3 _SpecularColor;
            half _RimPower;
            half _Roughness;
            float _ReflectionIntensity;
            /******************************************************************************/
            half _Opacity;
            half _OpacityMin;
            half _OpacityFalloff;
            CBUFFER_END

            half3 BlendNormals(half3 n1, half3 n2) {
                return normalize(half3(n1.xy + n2.xy, n1.z * n2.z));
            }

            Varyings vert(Attributes IN) {

                Varyings OUT;
                
                OUT.vertex = TransformObjectToHClip(IN.vertex.xyz);

                OUT.worldPos = mul(unity_ObjectToWorld, IN.vertex).xyz;

                OUT.uv = IN.uv.xy * _NormalTex_ST.xy + _NormalTex_ST.zw;
                OUT.uvRefection = IN.uv.xy * _ReflectionNormalTex_ST.xy + _ReflectionNormalTex_ST.zw;

                half3 worldNormal = normalize(mul(IN.normal, (float3x3)unity_WorldToObject));
                half3 worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, IN.tangent));
                half tangentSign = IN.tangent.w * unity_WorldTransformParams.w;
                half3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;

                OUT.TW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, OUT.worldPos.x);
                OUT.TW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, OUT.worldPos.y);
                OUT.TW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, OUT.worldPos.z);

                OUT.screenPos = ComputeScreenPos(OUT.vertex);

                half4 positionCS = TransformWorldToHClip(OUT.worldPos);
                OUT.screenPos_Depth = ComputeScreenPos(positionCS);

                OUT.worldNormal = worldNormal;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target {
                //half2 panner1 = (_Time.y * _WaveParams.xy + IN.uv);
                //half2 panner2 = (_Time.y * _WaveParams.zw + IN.uv);

                //half3 worldNormal = BlendNormals(UnpackNormal(tex2D(_NormalTex, panner1)), UnpackNormal(tex2D(_NormalTex, panner2)));
                //worldNormal = lerp(half3(0, 0, 1), worldNormal, _NormalScale);
                //worldNormal = normalize(half3(dot(IN.TW0.xyz, worldNormal), dot(IN.TW1.xyz, worldNormal), dot(IN.TW2, worldNormal)));

                half2 uvParam1 = _Time.y * _WaveSpeed.xx + half2(IN.worldPos.x, IN.worldPos.z) * _NormalTiling;
                half2 uvParam2 = _Time.y * - _WaveSpeed.xx + half2(IN.worldPos.x, IN.worldPos.z) * _NormalTiling2;
                half3 waveNormal = UnpackNormalScale(half4(BlendNormal(tex2D(_NormalTex, uvParam1).rgb, UnpackNormalScale(tex2D(_NormalTex2, uvParam2), 1)), 0), _NormalScale);
                waveNormal.z = lerp(1, waveNormal.z, saturate(_NormalScale));

                half2 panner3 = (_Time.y * _ReflectionParams.xy + IN.uvRefection);
                half2 panner4 = (_Time.y * _ReflectionParams.zw + IN.uvRefection);
                half3 refectionNormal = BlendNormals(UnpackNormal(tex2D(_ReflectionNormalTex, panner3)), UnpackNormal(tex2D(_ReflectionNormalTex, panner4)));
                refectionNormal = lerp(half3(0, 0, 1), refectionNormal, _NormalScale);
                refectionNormal = normalize(half3(dot(IN.TW0.xyz, refectionNormal), dot(IN.TW1.xyz, refectionNormal), dot(IN.TW2, refectionNormal)));

                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.worldPos);
                half NdotV = saturate(dot(waveNormal, viewDir));
                half3 halfDir = normalize(_LightDir.xyz + viewDir);

                half4 diffuse = _DiffuseColor * NdotV * 0.5;
                half3 specular = _SpecularColor.rgb * _WaterSpecular * pow(max(0, dot(waveNormal, halfDir)), _WaterSmoothness * 2560);
                half3 rim = pow(1 - saturate(NdotV), _RimPower) * _SpecularColor * 0.2;

                half3 color = diffuse + specular + rim;

                viewDir = normalize(viewDir);
                half3 reflectDirWS = reflect(-viewDir, refectionNormal);
                half3 reflectionProbeResult = GlossyEnvironmentReflection(reflectDirWS, _Roughness, 1);
                half2 screenUV = IN.screenPos.xy / IN.screenPos.w;

                half4 reflectionCol = tex2D(_ReflectionRT, screenUV);
                half3 finalCol = reflectionProbeResult + reflectionCol.xyz * _ReflectionIntensity;
                color *= 3;

                /******************************************************************************/

                half4 screenPos = IN.screenPos_Depth / IN.screenPos_Depth.w;
                half screenDepth = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(screenPos.xy), _ZBufferParams);
                half distanceDepth = abs(screenDepth - LinearEyeDepth(screenPos.z, _ZBufferParams));
                //half waterOpacity = (_OpacityMin + saturate(distanceDepth / _OpacityFalloff) * (1 - _OpacityMin)) * _Opacity;
                half waterOpacity = (_OpacityMin + saturate(distanceDepth / _OpacityFalloff) * (1 - _OpacityMin)) * _Opacity;

                return half4(finalCol * color, waterOpacity) ;
            }
            ENDHLSL
        }
    }
}