Shader "Demo/SimpleShadow/Mask3D-2" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" { }
        [Space(15)]
        _LightDirection ("LightDirection", vector) = (0.3, 0.1, -0.1, 0)
        [Header(Diffuse)]
        [Toggle]DiffuseSwitch ("Diffuse Switch", int) = 1
        _FrontLightColor ("Front Light Color", Color) = (1, 1, 1, 1)
        _BackLightColor ("Back Light Color", Color) = (1, 1, 1, 1)
        _DiffuseFrontIntensity ("Diffuse Front Intensity", float) = 0.7
        _DiffuseBackIntensity ("Diffuse Back Intensity", float) = 0.3
        [Header(Specular)]
        [Toggle]SpecularSwitch ("Specular Switch", int) = 1
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularIntensity ("SpecularIntensity", Range(0, 10)) = 5
        _Gloss ("Gloss", Range(0, 2)) = 0.5
        [Header(Shadow)]
        [Toggle]ShadowSwitch ("Shadow Switch", int) = 1
        _ShadowColor ("Shadow Color", Color) = (0, 0, 0, 0.5)
        _ShadowFalloff ("Shadow Fall Off", float) = 0
        _ShadowAlphaClipThreshold ("Shadow Alpha Clip Threshold", Range(0, 1)) = 1
        [Header(Alpha)]
        _Alpah ("Alpha", Range(0, 1)) = 1
        [Toggle]AlphaClipping ("Alpah Clipping", int) = 0
        _AlphaClipThreshold ("Alpha Clip Threshold", Range(0, 1)) = 1
        [Header(Other Settings)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend ("SrcBlend   [One  SrcAlpha]", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend ("DstBlend   [Zero  OneMinusSrcAlpha]", float) = 0
        [Enum(On, 1, Off, 0)]_ZWrite ("ZWrite        [On  Off]", float) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" }

        Pass {
            Tags { "LightMode" = "UniversalForward" }

            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]


            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature DIFFUSESWITCH_ON
            #pragma shader_feature SPECULARSWITCH_ON
            #pragma shader_feature ALPHACLIPPING_ON

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
            float4 _LightDirection;
            half4 _FrontLightColor;
            half4 _BackLightColor;
            float _DiffuseFrontIntensity;
            float _DiffuseBackIntensity;
            half4 _SpecularColor;
            float _SpecularIntensity;
            float _Gloss;
            half _Alpah;
            float _AlphaClipThreshold;
            float4 _ShadowColor;
            float _ShadowFalloff;
            float _ShadowAlphaClipThreshold;
            CBUFFER_END

            Varyings vert(Attributes IN) {

                Varyings OUT;
                
                OUT.vertex = TransformObjectToHClip(IN.vertex.xyz);
                
                #if defined(DIFFUSESWITCH_ON) || defined(SPECULARSWITCH_ON)
                    OUT.worldNormal = mul(IN.normal, (float3x3)unity_WorldToObject);
                    #if defined(SPECULARSWITCH_ON)
                        //OUT.worldPos = mul(unity_ObjectToWorld, IN.vertex).xyz;
                        OUT.worldPos = TransformObjectToWorld(IN.vertex.xyz);
                    #else
                        OUT.worldPos = half3(0, 0, 0);
                    #endif
                #else
                    OUT.worldNormal = half3(0, 0, 0);
                    OUT.worldPos = half3(0, 0, 0);
                #endif

                OUT.uv = IN.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                float3 pos = OUT.vertex;
                //if (OUT.worldPos.x > 1) {
                //    pos = float3(1, OUT.worldPos.y, OUT.worldPos.z);
                //    OUT.vertex = TransformWorldToHClip(pos);
                //}
                //if (OUT.worldPos.x < - 1) {
                //    pos = float3(-1, OUT.worldPos.y, OUT.worldPos.z);
                //    OUT.vertex = TransformWorldToHClip(pos);
                //}
                //if (OUT.worldPos.z > 1) {
                //    pos = float3(OUT.worldPos.x, OUT.worldPos.y, 1);
                //    OUT.vertex = TransformWorldToHClip(pos);
                //}
                //if (OUT.worldPos.z < - 1) {
                //    pos = float3(OUT.worldPos.x, OUT.worldPos.y, -1);
                //    OUT.vertex = TransformWorldToHClip(pos);
                //}

                if (OUT.worldPos.x > 0.9) {
                    float ty = 1 - min((OUT.worldPos.x - 0.9), 1);
                    pos = float3(OUT.worldPos.x, OUT.worldPos.y * ty, OUT.worldPos.z);
                    OUT.vertex = TransformWorldToHClip(pos);
                }
                if (OUT.worldPos.x < - 0.9) {
                    float ty = 1 + max((OUT.worldPos.x + 0.9), -1);
                    pos = float3(OUT.worldPos.x, OUT.worldPos.y * ty, OUT.worldPos.z);
                    OUT.vertex = TransformWorldToHClip(pos);
                }
                if (OUT.worldPos.z > 0.9) {
                    float ty = 1 - min((OUT.worldPos.z - 0.9), 1);
                    pos = float3(OUT.worldPos.x, OUT.worldPos.y * ty, OUT.worldPos.z);
                    OUT.vertex = TransformWorldToHClip(pos);
                }
                if (OUT.worldPos.z < - 0.9) {
                    float ty = 1 + max((OUT.worldPos.z + 0.9), -1);
                    pos = float3(OUT.worldPos.x, OUT.worldPos.y * ty, OUT.worldPos.z);
                    OUT.vertex = TransformWorldToHClip(pos);
                }

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target {

                half4 albedo = tex2D(_MainTex, IN.uv);

                float3 worldNormal = normalize(IN.worldNormal);
                float3 worldLightDir = normalize(_LightDirection.xyz);

                #if defined(DIFFUSESWITCH_ON)
                    float halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                    half3 diffuse = _FrontLightColor.rgb * albedo.rgb * halfLambert * _DiffuseFrontIntensity;
                    float oneMinusHalfLambert = 1 - halfLambert;
                    diffuse += _BackLightColor.rgb * albedo.rgb * oneMinusHalfLambert * _DiffuseBackIntensity;
                #endif

                #if defined(SPECULARSWITCH_ON)
                    float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.worldPos.xyz);
                    float3 halfDir = normalize(worldLightDir + viewDir);
                    half3 specular = _SpecularColor.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss * 256) * _SpecularIntensity;
                #endif

                half3 color = albedo.rgb;
                #if defined(DIFFUSESWITCH_ON)
                    color = diffuse;
                #endif
                #if defined(SPECULARSWITCH_ON)
                    color += specular;
                #endif

                #if defined(ALPHACLIPPING_ON)
                    half alphaTest = albedo.a;
                    clip(alphaTest - _AlphaClipThreshold);
                    _Alpah *= alphaTest;
                #endif

                float alpha = 0;
                if ((IN.worldPos.x < 2 && IN.worldPos.x > - 2) && (IN.worldPos.z < 2 && IN.worldPos.z > - 2)) {
                    alpha = 1;
                }

                return half4(color, alpha);
            }
            ENDHLSL
        }
    }
}