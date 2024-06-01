Shader "SyntyStudios/Water_Foam 2.0" {
    Properties {
        _Opacity ("Opacity", Range(0, 1)) = 1
        _OpacityFalloff ("Opacity Falloff", Float) = 1
        _OpacityMin ("Opacity Min", Range(0, 1)) = 0.5
        _Specular ("Specular", Range(0, 1)) = 0.141
        _Smoothness ("Smoothness", Float) = 2
        _ReflectionPower ("Reflection Power", Range(0, 1)) = 0.346
        [Header(Colour)]_ShallowColour ("Shallow Colour", Color) = (0.9607843, 0.7882353, 0.5764706, 0)
        _DeepColour ("Deep Colour", Color) = (0.04705882, 0.3098039, 0.1960784, 0)
        _VeryDeepColour ("Very Deep Colour", Color) = (0.05959199, 0.08247829, 0.191, 0)
        _ShallowFalloff ("ShallowFalloff", Float) = 0.4
        _OverallFalloff ("OverallFalloff", Range(0, 10)) = 0.76
        _Depth ("Depth", Float) = 0.28
        [Header(Waves)]_RipplesNormal ("Ripples Normal", 2D) = "white" { }
        _NormalTiling ("Normal Tiling", Float) = 0.2
        _RipplesNormal2 ("Ripples Normal 2", 2D) = "bump" { }
        _NormalTiling2 ("Normal Tiling 2", Float) = 0.2
        _NormalScale ("Normal Scale", Range(0, 1)) = 0.669
        _RippleSpeed ("Ripple Speed", Range(0, 1)) = 0.092
        [Header(Reflection)]_ReflectionIntensity ("Reflection Intensity", Range(0, 1)) = 0.5
        _ReflectionColor ("Reflection Color", Color) = (1, 1, 1, 1)
        _ReflectionfWave ("Reflection Wave", Range(0, 1)) = 0
        [Header(Foam)]_FoamColor ("Foam Color", Color) = (1, 1, 1, 1)
        _NoiseTexture ("NoiseTexture", 2D) = "white" { }
        _FoamSpeed ("Foam Speed", Range(0, 1)) = 0.125
        _FoamScale ("Foam Scale", Range(0, 1)) = 0.2
        _FoamDistance ("Foam Distance", Range(0, 1)) = 0.05
        _FoamOpacity ("_FoamOpacity", Range(0, 1)) = 0.65
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }
        Cull Back
        Pass {
            Tags { "LightMode" = "UniversalForward" }
            
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            #pragma multi_compile_instancing

            #define REQUIRE_DEPTH_TEXTURE

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput {
                float4 clipPos : SV_POSITION;
                float4 lightmapUVOrVertexSH : TEXCOORD0;
                half4 fogFactorAndVertexLight : TEXCOORD1;
                float2 uv : TEXCOORD2;
                float4 tSpace0 : TEXCOORD3;
                float4 tSpace1 : TEXCOORD4;
                float4 tSpace2 : TEXCOORD5;
                float4 screenPos : TEXCOORD6;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _DeepColour;
            float4 _FoamColor;
            float4 _ShallowColour;
            float4 _VeryDeepColour;
            float _Specular;
            float _Smoothness;
            float _ReflectionPower;
            float _OpacityFalloff;
            float _NormalScale;
            float _NormalTiling2;
            float _RippleSpeed;
            float _Depth;
            float _OverallFalloff;
            float _ShallowFalloff;
            float _FoamSpread;
            float _FoamShoreline;
            float _FoamFalloff;
            float _OpacityMin;
            float _NormalTiling;
            float _Opacity;
            float _ReflectionIntensity;
            half4 _ReflectionColor;
            float _ReflectionfWave;

            float4 _NoiseTexture_ST;
            float _FoamSpeed;
            float _FoamScale;
            float _FoamDistance;
            float _FoamOpacity;

            CBUFFER_END
            sampler2D _RipplesNormal;
            sampler2D _RipplesNormal2;
            sampler2D _NoiseTexture;

            inline float4 ASE_ComputeGrabScreenPos(float4 pos) {
                float scale = 1.0;
                float4 o = pos;
                o.y = pos.w * 0.5f;
                o.y = (pos.y - o.y) * _ProjectionParams.x * scale + o.y;
                return o;
            }
            
            float3 mod3D289(float3 x) {
                return x - floor(x / 289.0) * 289.0;
            }
            float4 mod3D289(float4 x) {
                return x - floor(x / 289.0) * 289.0;
            }
            float4 permute(float4 x) {
                return mod3D289((x * 34.0 + 1.0) * x);
            }
            float4 taylorInvSqrt(float4 r) {
                return 1.79284291400159 - r * 0.85373472095314;
            }
            float snoise(float3 v) {
                const float2 C = float2(1.0 / 6.0, 1.0 / 3.0);
                float3 i = floor(v + dot(v, C.yyy));
                float3 x0 = v - i + dot(i, C.xxx);
                float3 g = step(x0.yzx, x0.xyz);
                float3 l = 1.0 - g;
                float3 i1 = min(g.xyz, l.zxy);
                float3 i2 = max(g.xyz, l.zxy);
                float3 x1 = x0 - i1 + C.xxx;
                float3 x2 = x0 - i2 + C.yyy;
                float3 x3 = x0 - 0.5;
                i = mod3D289(i);
                float4 p = permute(permute(permute(i.z + float4(0.0, i1.z, i2.z, 1.0)) + i.y + float4(0.0, i1.y, i2.y, 1.0)) + i.x + float4(0.0, i1.x, i2.x, 1.0));
                float4 j = p - 49.0 * floor(p / 49.0);
                float4 x_ = floor(j / 7.0);
                float4 y_ = floor(j - 7.0 * x_);
                float4 x = (x_ * 2.0 + 0.5) / 7.0 - 1.0;
                float4 y = (y_ * 2.0 + 0.5) / 7.0 - 1.0;
                float4 h = 1.0 - abs(x) - abs(y);
                float4 b0 = float4(x.xy, y.xy);
                float4 b1 = float4(x.zw, y.zw);
                float4 s0 = floor(b0) * 2.0 + 1.0;
                float4 s1 = floor(b1) * 2.0 + 1.0;
                float4 sh = -step(h, 0.0);
                float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
                float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
                float3 g0 = float3(a0.xy, h.x);
                float3 g1 = float3(a0.zw, h.y);
                float3 g2 = float3(a1.xy, h.z);
                float3 g3 = float3(a1.zw, h.w);
                float4 norm = taylorInvSqrt(float4(dot(g0, g0), dot(g1, g1), dot(g2, g2), dot(g3, g3)));
                g0 *= norm.x;
                g1 *= norm.y;
                g2 *= norm.z;
                g3 *= norm.w;
                float4 m = max(0.6 - float4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
                m = m * m;
                m = m * m;
                float4 px = float4(dot(x0, g0), dot(x1, g1), dot(x2, g2), dot(x3, g3));
                return 42.0 * dot(m, px);
            }

            VertexOutput vert(VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 positionVS = TransformWorldToView(positionWS);
                float4 positionCS = TransformWorldToHClip(positionWS);

                VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);

                o.tSpace0 = float4(normalInput.normalWS, positionWS.x);
                o.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
                o.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);

                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
                OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);

                half3 vertexLight = VertexLighting(positionWS, normalInput.normalWS);

                o.fogFactorAndVertexLight = half4(0, vertexLight);
                
                o.clipPos = positionCS;
                o.screenPos = ComputeScreenPos(positionCS);

                o.uv.xy = TRANSFORM_TEX(v.texcoord1, _NoiseTexture);

                return o;
            }

            half4 frag(VertexOutput IN) : SV_Target {
                UNITY_SETUP_INSTANCE_ID(IN);
                float3 WorldPosition = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
                float3 WorldViewDirection = _WorldSpaceCameraPos.xyz - WorldPosition;
                float4 ScreenPos = IN.screenPos;
                WorldViewDirection = normalize(WorldViewDirection);
                float4 screenPosNorm = ScreenPos / ScreenPos.w;
                float screenDepth170 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(screenPosNorm.xy), _ZBufferParams);
                float distanceDepth170 = abs((screenDepth170 - LinearEyeDepth(screenPosNorm.z, _ZBufferParams)) / (_Depth));
                float temp_output_99_0 = pow(distanceDepth170, _OverallFalloff);
                float temp_output_235_0 = (temp_output_99_0 + _ShallowFalloff);
                float4 lerpResult115 = lerp(_ShallowColour, _DeepColour, temp_output_235_0);
                float4 lerpResult177 = lerp(_DeepColour, _VeryDeepColour, saturate((temp_output_99_0 - 1.0)));
                float4 temp_output_175_0 = (temp_output_235_0 < 1.0 ?                                              lerpResult115 : lerpResult177);
                float4 grabScreenPos = ASE_ComputeGrabScreenPos(ScreenPos);
                float4 grabScreenPosNorm = grabScreenPos / grabScreenPos.w;
                float4 Refraction107 = float4(SHADERGRAPH_SAMPLE_SCENE_COLOR(((grabScreenPosNorm).xy)), 1.0);
                float4 lerpResult121 = lerp(temp_output_175_0, Refraction107, temp_output_175_0);

                float2 appendResult93 = (float2(WorldPosition.x, WorldPosition.z));
                float2 panner119 = _Time.y * _RippleSpeed.xx + appendResult93 * _NormalTiling;
                float2 panner118 = _Time.y * - _RippleSpeed.xx + appendResult93 * _NormalTiling2;
                float4 tex2DNormal1 = tex2D(_RipplesNormal, panner119);
                float4 tex2DNormal2 = tex2D(_RipplesNormal2, panner118);
                float3 unpack151 = UnpackNormalScale(float4(BlendNormal(tex2DNormal1.rgb, UnpackNormalScale(tex2DNormal2, 1.0f)), 0.0), _NormalScale);
                unpack151.z = lerp(1, unpack151.z, saturate(_NormalScale));
                
                float screenDepth234 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(screenPosNorm.xy), _ZBufferParams);
                float distanceDepth234 = abs(screenDepth234 - LinearEyeDepth(screenPosNorm.z, _ZBufferParams));
                float waterOpacity218 = (_OpacityMin + saturate(distanceDepth234 / _OpacityFalloff) * (1 - _OpacityMin)) * _Opacity;
                
                float3 Albedo = lerpResult121;
                float3 Normal = unpack151;
                float3 Emission = half4(0, 0, 0, 0);
                float3 Specular = _Specular.xxx;
                float Metallic = 0;
                float Smoothness = _Smoothness * _ReflectionPower;
                float Occlusion = 1;
                float Alpha = waterOpacity218;

                InputData inputData;
                inputData.positionWS = WorldPosition;
                inputData.viewDirectionWS = WorldViewDirection;
                inputData.shadowCoord = float4(0, 0, 0, 0);

                float3 WorldNormal = normalize(IN.tSpace0.xyz);
                float3 WorldTangent = IN.tSpace1.xyz;
                float3 WorldBiTangent = IN.tSpace2.xyz;
                inputData.normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
                inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);

                inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;

                float3 SH = IN.lightmapUVOrVertexSH.xyz;

                inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS);
                
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);
                inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

                half4 color = UniversalFragmentPBR(
                    inputData,
                    Albedo,
                    Metallic,
                    Specular,
                    Smoothness,
                    Occlusion,
                    Emission,
                    Alpha);

                float4 screenPos_Norm = IN.screenPos / IN.screenPos.w;
                //在OpenGL中，NDC的z分量范围为[-1,1]，在DirectX中，NDC的z分量范围为[0,1]
                screenPos_Norm.z = (UNITY_NEAR_CLIP_VALUE >= 0) ?  screenPos_Norm.z : screenPos_Norm.z * 0.5 + 0.5;
                float sceneRawDepth = SampleSceneDepth(screenPos_Norm);
                float sceneEyeDepth = LinearEyeDepth(sceneRawDepth, _ZBufferParams);
                float distanceDepth = abs((sceneEyeDepth - 1.0 / (_ZBufferParams.z * screenPos_Norm.z + _ZBufferParams.w)) / (tex2D(_NoiseTexture, (_FoamSpeed * 2.5 * _Time.y) + (IN.uv * (30 + _FoamScale * -30))).r * _FoamDistance * 10));
                float clampDepth = clamp(distanceDepth, 0, 1);
                float foam = (1 - clampDepth) * _FoamOpacity;

                half4 foamColor = _FoamColor * foam ;

                return color + foamColor;
            }

            ENDHLSL
        }
    }
    Fallback "Standard"
}