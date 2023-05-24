Shader "Light/Simple Lighting Simulation" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" { }
        _DiffuseFrontIntensity ("Diffuse Front Intensity", Range(0, 2)) = 0.7
        _DiffuseBackIntensity ("Diffuse Back Intensity", Range(0, 2)) = 0.3
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
        _LightColor ("Light Color", Color) = (1, 1, 1, 1)
        _FinalColorIntensity ("Final Color Intensity", Range(1, 10)) = 2
        _Alpah ("Alpha", Range(0, 1)) = 1
        _LightX ("LightX", Range(-1, 1)) = 0.3
        _LightY ("LightY", Range(-1, 1)) = 0.1
        _LightZ ("LightZ", Range(-1, 1)) = -0.1
        _SrcBlend ("SrcBlend", float) = 1
       _DstBlend ("DstBlend", float) = 0
        _ZWrite ("ZWrite", float) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
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
            float4 _Specular;
            float _Gloss;
            float4 _LightColor;
            float _DiffuseBackIntensity;
            float _FinalColorIntensity;
            float _Alpah;
            float _LightX;
            float _LightY;
            float _LightZ;
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

                float3 albedo = tex2D(_MainTex, IN.uv).rgb;

                float3 worldNormal = normalize(IN.worldNormal);
                float3 worldLightDir = normalize(float3(_LightX, _LightY, _LightZ));
                
                float halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                float3 diffuse = _LightColor.rgb * albedo * halfLambert * _DiffuseFrontIntensity;
                
                float oneMinusHalfLambert = 1 - halfLambert;
                diffuse += _LightColor.rgb * albedo * oneMinusHalfLambert * _DiffuseBackIntensity;

                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.worldPos.xyz);
                float3 halfDir = normalize(worldLightDir + viewDir);
                float3 specular = _LightColor.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                return float4(diffuse + specular, _Alpah) * _FinalColorIntensity  ;
            }
            ENDHLSL
        }
    }
}