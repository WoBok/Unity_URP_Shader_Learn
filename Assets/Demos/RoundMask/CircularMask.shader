Shader "URP Shader/CircularMask" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" { }
        _DiffuseFrontIntensity ("Diffuse Front Intensity", float) = 0.7
        _DiffuseBackIntensity ("Diffuse Back Intensity", float) = 0.3
        _Gloss ("Gloss", Range(0, 1)) = 0.5
        _Balala ("Balala", Range(1, 10)) = 5
        _FrontLightColor ("Front Light Color", Color) = (1, 1, 1, 1)
        _BackLightColor ("Back Light Color", Color) = (1, 1, 1, 1)
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Alpah ("Alpha", Range(0, 1)) = 1
        _LightX ("LightX", Range(-1, 1)) = 0.3
        _LightY ("LightY", Range(-1, 1)) = 0.1
        _LightZ ("LightZ", Range(-1, 1)) = -0.1
        _FadeRadius ("Fade Radius", float) = 1.6
        _Radius ("Radius", float) = 1.6
        _Range ("Range", vector) = (-0.0165, 1.0095, 0, 0)
        [Enum(UnityEngine.Rendering.CullMode)]_Cull ("Cull", float) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" }

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            Cull[_Cull]

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
                float range : TEXCOORD3;
                float fade : TEXCOORD4;
            };
            
            CBUFFER_START(UnityPerMaterial)
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _DiffuseFrontIntensity;
            float _Gloss;
            float _Balala;
            half4 _FrontLightColor;
            half4 _BackLightColor;
            half4 _SpecularColor;
            float _DiffuseBackIntensity;
            half _Alpah;
            float _LightX;
            float _LightY;
            float _LightZ;
            float _Radius;
            float _FadeRadius;
            float2 _Range;
            CBUFFER_END

            Varyings vert(Attributes IN) {

                Varyings OUT;
                
                OUT.vertex = TransformObjectToHClip(IN.vertex.xyz);
                
                OUT.worldNormal = mul(IN.normal, (float3x3)unity_WorldToObject);

                OUT.worldPos = mul(unity_ObjectToWorld, IN.vertex).xyz;

                OUT.uv = IN.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                float deltaX = (OUT.worldPos.x - _Range.x);
                float deltaZ = (OUT.worldPos.z - _Range.y);
                float currentRadius = sqrt(deltaX * deltaX + deltaZ * deltaZ);

                OUT.range = step(currentRadius, _Radius);

                OUT.fade = (_FadeRadius - currentRadius) / (_FadeRadius - _Radius);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target {

                float3 albedo = tex2D(_MainTex, IN.uv).rgb;

                float3 worldNormal = normalize(IN.worldNormal);
                float3 worldLightDir = normalize(float3(_LightX, _LightY, _LightZ));
                
                float halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                float3 diffuse = _FrontLightColor.rgb * albedo * halfLambert * _DiffuseFrontIntensity;
                
                float oneMinusHalfLambert = 1 - halfLambert;
                diffuse += _BackLightColor.rgb * albedo * oneMinusHalfLambert * _DiffuseBackIntensity;

                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.worldPos.xyz);
                float3 halfDir = normalize(worldLightDir + viewDir);
                float3 specular = _SpecularColor.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss * 256) * _Balala;

                return float4(diffuse + specular, _Alpah * IN.range + IN.fade)   ;
            }
            ENDHLSL
        }
    }
}