Shader "Demo/SimpleShadow/Light" {
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
        _SpecularIntensity ("SpecularIntensity", Range(1, 10)) = 5
        _Gloss ("Gloss", Range(0, 2)) = 0.5
        [Header(Alpha)]
        _Alpah ("Alpha", Range(0, 1)) = 1
        [Toggle]AlphaClipping ("Alpah Clipping", int) = 0
        _AlphaClipThreshold ("Alpha Clip Threshold", Range(0, 1)) = 1
        [Header(Other Settings)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend ("SrcBlend   [One  SrcAlpha]", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend ("DstBlend   [Zero  OneMinusSrcAlpha]", float) = 0
        [Enum(On,1,Off,0)]_ZWrite ("ZWrite        [On  Off]", float) = 1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
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

                half4 albedo = tex2D(_MainTex, IN.uv);//Albedo决定了多少红绿蓝不被反射
                /*
                       反照率指的是光线被物体或表面反射回来的比例，涵盖了所有波长的光。物体的反照率不同波长的光线可能会有所差异。在可见光谱范围内，
                不同颜色的光波长对应不同的颜色。当光线照射到物体上时，物体的反照率会影响不同波长光的反射程度。
                       例如，对于红色物体，它能够吸收大部分的非红色波长光，并反射红色波长光，因此我们看到它是红色的。相应地，对于蓝色物体，它吸收
                大部分非蓝色波长光，并反射蓝色波长光。
                       因此，反照率并不局限于特定的波长范围，而是表示物体对所有波长光线的反射能力。不同波长的光线在反射过程中可能会被物体吸收、散
                射或反射，最终形成我们所观察到的颜色和亮度。
                */
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
    }
}