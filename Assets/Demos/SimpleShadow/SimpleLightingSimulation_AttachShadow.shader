Shader "Demo/SimpleShadow/Simple Lighting Simulation_Attach Shadow" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" { }
        _LightDirection ("LightDirection", vector) = (0.3, 0.1, -0.1, 0)
        _Alpah ("Alpha", Range(0, 1)) = 1
        [Toggle]AlpahClipping ("Alpah Clipping", int) = 0
        _AlphaClipThreshold ("Alpha Clip Threshold", Range(0, 1)) = 1
        [Header(Diffuse)]_FrontLightColor ("Front Light Color", Color) = (1, 1, 1, 1)
        _BackLightColor ("Back Light Color", Color) = (1, 1, 1, 1)
        _DiffuseFrontIntensity ("Diffuse Front Intensity", float) = 0.7
        _DiffuseBackIntensity ("Diffuse Back Intensity", float) = 0.3
        [Header(Specular)]_SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularIntensity ("SpecularIntensity", Range(1, 10)) = 5
        _Gloss ("Gloss", Range(0, 2)) = 0.5
        [Header(Shadow)]_ShadowColor ("Shadow Color", Color) = (0, 0, 0, 0.5)
        _ShadowFalloff ("Shadow Fall Off", float) = 0
        [Header(Other Setting)]_SrcBlend ("SrcBlend", float) = 1
        _DstBlend ("DstBlend", float) = 0
        _ZWrite ("ZWrite", float) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue"="Transparent" }

        UsePass "Shadow/Simple Shadow Simulation/Shadow"

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
                float2 uv : TEXCOORD2;
            };
            
            CBUFFER_START(UnityPerMaterial)
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _DiffuseFrontIntensity;
            float _Gloss;
            float _SpecularIntensity;
            half4 _FrontLightColor;
            half4 _BackLightColor;
            half4 _SpecularColor;
            float _DiffuseBackIntensity;
            half _Alpah;
            float _AlphaClipThreshold;
            float4 _LightDirection;
            CBUFFER_END

            Varyings vert(Attributes IN) {

                Varyings OUT;
                
                OUT.vertex = TransformObjectToHClip(IN.vertex.xyz);
                
                OUT.worldNormal = mul(IN.normal, (float3x3)unity_WorldToObject);

                OUT.worldPos = mul(unity_ObjectToWorld, IN.vertex).xyz;

                OUT.uv = IN.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target {

                half4 albedo = tex2D(_MainTex, IN.uv);

                float3 worldNormal = normalize(IN.worldNormal);
                float3 worldLightDir = normalize(_LightDirection.xyz);
                
                float halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                half3 diffuse = _FrontLightColor.rgb * albedo.rgb * halfLambert * _DiffuseFrontIntensity;
                float oneMinusHalfLambert = 1 - halfLambert;
                diffuse += _BackLightColor.rgb * albedo.rgb * oneMinusHalfLambert * _DiffuseBackIntensity;

                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.worldPos.xyz);
                float3 halfDir = normalize(worldLightDir + viewDir);
                half3 specular = _SpecularColor.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss * 256) * _SpecularIntensity;
                
                half Alpha = albedo.a;
                clip(Alpha - _AlphaClipThreshold);
                
                return half4(diffuse + specular, _Alpah * Alpha);
            }
            ENDHLSL
        }
    }
}