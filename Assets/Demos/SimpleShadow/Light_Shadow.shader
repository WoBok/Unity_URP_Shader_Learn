Shader "Light/Light and Shadow" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" { }
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
        _SpecularIntensity ("SpecularIntensity", Range(1, 10)) = 5
        _Gloss ("Gloss", Range(0, 2)) = 0.5
        [Header(Alpha)]
        _Alpah ("Alpha", Range(0, 1)) = 1
        [Toggle]AlphaClipping ("Alpah Clipping", int) = 0
        _AlphaClipThreshold ("Alpha Clip Threshold", Range(0, 1)) = 1
        [Header(Shadow)]
        [Toggle]ShadowSwitch ("Shadow Switch", int) = 1
        _ShadowColor ("Shadow Color", Color) = (0, 0, 0, 0.5)
        _ShadowFalloff ("Shadow Fall Off", float) = 0
        _ShadowAlphaClipThreshold ("Shadow Alpha Clip Threshold", Range(0, 1)) = 1
        [Header(Other Settings)]
        _SrcBlend ("SrcBlend   [1  5]", float) = 1
        _DstBlend ("DstBlend   [0  10]", float) = 0
        _ZWrite ("ZWrite        [1  0]", float) = 1
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

            #pragma shader_feature ALPHACLIPPING_ON
            #pragma shader_feature DIFFUSESWITCH_ON
            #pragma shader_feature SPECULARSWITCH_ON

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
            float _ShadowFalloff;
            float4 _ShadowColor;
            float _ShadowAlphaClipThreshold;
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

                return half4(color, _Alpah);
            }
            ENDHLSL
        }

        Pass {
            Tags { "LightMode" = "SRPDefaultUnlit" }

            Name "Shadow"

            Stencil {
                Ref 0
                Comp Equal
                Pass incrWrap
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature ALPHACLIPPING_ON
            #pragma shader_feature SHADOWSWITCH_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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
            float _ShadowFalloff;
            float4 _ShadowColor;
            float _ShadowAlphaClipThreshold;
            CBUFFER_END

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            float3 ShadowProjectPos(float4 vertPos) {
                float3 shadowPos;
                float3 worldPos = mul(unity_ObjectToWorld, vertPos).xyz;
                float3 lightDirection = normalize(_LightDirection.xyz);
                shadowPos.y = min(worldPos.y, _LightDirection.w);
                shadowPos.xz = worldPos.xz - lightDirection.xz * max(0, worldPos.y - _LightDirection.w);
                return shadowPos;
            }

            v2f vert(appdata v) {
                v2f o;
                #if defined(SHADOWSWITCH_ON)
                    float3 shadowPos = ShadowProjectPos(v.vertex);
                    o.vertex = TransformWorldToHClip(shadowPos);
                    float3 center = float3(unity_ObjectToWorld[0].w, _LightDirection.w, unity_ObjectToWorld[2].w);
                    float falloff = 1 - saturate(distance(shadowPos, center) * _ShadowFalloff);
                    o.color = _ShadowColor;
                    o.color.a *= falloff;
                #else
                    o.vertex = TransformObjectToHClip(v.vertex.xyz);
                    o.color=half4(0,0,0,0);
                #endif
                    o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            half4 frag(v2f i) : SV_Target {
                #if defined(SHADOWSWITCH_ON)
                    #if defined(ALPHACLIPPING_ON)
                        half4 alphaTest = tex2D(_MainTex, i.uv).a;
                        clip(alphaTest - _ShadowAlphaClipThreshold);
                        i.color.a *= alphaTest;
                    #endif
                    return i.color;
                #else
                    return half4(0, 0, 0, 0);
                #endif
            }
            ENDHLSL
        }
    }
}