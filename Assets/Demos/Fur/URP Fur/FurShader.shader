Shader "Light/Fur Shader" {
    Properties {
        _MainTex ("Main Tex", 2D) = "white" { }
        _LightDirection ("Light Direction", vector) = (0.3, 0.1, -0.1, 0)
        _Alpah ("Alpha", Range(0, 1)) = 1
        [Header(Diffuse)]
        _FrontLightColor ("Front Light Color", Color) = (1, 1, 1, 1)
        _BackLightColor ("Back Light Color", Color) = (1, 1, 1, 1)
        _DiffuseFrontIntensity ("Diffuse Front Intensity", float) = 0.7
        _DiffuseBackIntensity ("Diffuse Back Intensity", float) = 0.3
        [Header(Specular)]
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularIntensity ("Specular Intensity", Range(1, 10)) = 5
        _Gloss ("Gloss", Range(0, 2)) = 0.5
        [Header(Fur)]
        _FurPatternTex ("Fur Pattern", 2D) = "white" { }
        _FurLength ("Fur Length", Range(0.0, 1)) = 0.5
        _FurDensity ("Fur Density", Range(0, 2)) = 0.11
        _FurThinness ("Fur Thinness", Range(0.01, 10)) = 1
        _FurShading ("Fur Shading", Range(0.0, 1)) = 0.25
        _ForceGlobal ("Force Global", Vector) = (0, 0, 0, 0)
        _ForceLocal ("Force Local", Vector) = (0, 0, 0, 0)
        [Header(Other Setting)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend ("SrcBlend   [One  SrcAlpha]", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend ("DstBlend   [Zero  OneMinusSrcAlpha]", float) = 0
        [Enum(On, 1, Off, 0)]_ZWrite ("ZWrite        [On  Off]", float) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            Tags { "LightMode" = "UniversalForward" }

            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                half4 uv : TEXCOORD2;
            };
            
            sampler2D _MainTex;
            sampler2D _FurPatternTex;
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;

            float3 _LightDirection;

            half4 _FrontLightColor;
            half4 _BackLightColor;
            float _DiffuseFrontIntensity;
            float _DiffuseBackIntensity;

            half4 _SpecularColor;
            float _SpecularIntensity;
            float _Gloss;

            half _Alpah;

            half4 _FurPatternTex_ST;
            half _FurLength;
            half _FurDensity;
            half _FurThinness;
            half _FurShading;

            float4 _ForceGlobal;
            float4 _ForceLocal;

            float _FURSTEP;
            CBUFFER_END

            Varyings vert(Attributes IN) {
                Varyings OUT;

                float3 P = IN.vertex.xyz + IN.normal * _FurLength * _FURSTEP;
                P += clamp(mul(unity_WorldToObject, _ForceGlobal).xyz + _ForceLocal.xyz, -1, 1) * pow(_FURSTEP, 3) * _FurLength;
                
                OUT.vertex = TransformObjectToHClip(P);
                OUT.worldPos = TransformObjectToWorld(P);
                OUT.worldNormal = TransformObjectToWorldNormal(IN.normal);

                OUT.uv.xy = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.uv.zw = TRANSFORM_TEX(IN.uv, _FurPatternTex);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target {

                float3 albedo = tex2D(_MainTex, IN.uv.xy).rgb;

                float3 worldNormal = normalize(IN.worldNormal);
                float3 worldLightDir = normalize(_LightDirection);
                
                float halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                float3 diffuse = _FrontLightColor.rgb * albedo * halfLambert * _DiffuseFrontIntensity;
                
                float oneMinusHalfLambert = 1 - halfLambert;
                diffuse += _BackLightColor.rgb * albedo * oneMinusHalfLambert * _DiffuseBackIntensity;

                diffuse -= (pow(1 - _FURSTEP, 3)) * _FurShading;

                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.worldPos.xyz);
                float3 halfDir = normalize(worldLightDir + viewDir);
                float3 specular = _SpecularColor.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss * 256) * _SpecularIntensity;


                half3 color = diffuse + specular;
                
                half3 noise = tex2D(_FurPatternTex, IN.uv.zw * _FurThinness).rgb;
                half alpha = clamp(noise - (_FURSTEP * _FURSTEP) * _FurDensity, 0, 1);
                alpha *= _Alpah;

                return half4(color, alpha);
            }
            ENDHLSL
        }
    }
}