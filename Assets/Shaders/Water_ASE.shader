// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "SyntyStudios/Water" {
    Properties {
        [ASEBegin]_Opacity ("Opacity", Range(0, 1)) = 1
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
        [Header(Foam)]_FoamColor ("Foam Color", Color) = (0.5215687, 0.8980392, 0.8470588, 0)
        _FoamShoreline ("Foam Shoreline", Range(0, 1)) = 0
        _FoamSpread ("Foam Spread", Float) = 0.019
        _FoamFalloff ("Foam Falloff", Float) = -56
        [Header(Waves)]_RipplesNormal ("Ripples Normal", 2D) = "white" { }
        _NormalTiling ("Normal Tiling", Float) = 0.2
        _RipplesNormal2 ("Ripples Normal 2", 2D) = "bump" { }
        _NormalTiling2 ("Normal Tiling 2", Float) = 0.2
        _NormalScale ("Normal Scale", Range(0, 1)) = 0.669
        _RippleSpeed ("Ripple Speed", Range(0, 1)) = 0.092
    }

    SubShader {
        LOD 0

        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }
        Cull Back
        AlphaToMask Off
        Pass {
            
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Offset 0, 0
            ColorMask RGBA

            HLSLPROGRAM
            #define _NORMAL_DROPOFF_TS 1
            #pragma multi_compile_instancing

            #define ASE_FOG 1
            #define _EMISSION
            #define _NORMALMAP 1
            #define REQUIRE_DEPTH_TEXTURE 1//ÐèÒª±£Áô

            #pragma vertex vert
            #pragma fragment frag

            #define SHADERPASS_FORWARD

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"


            #define ASE_NEEDS_FRAG_SCREEN_POSITION
            #define ASE_NEEDS_FRAG_WORLD_POSITION


            struct VertexInput {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
                float4 ase_tangent : TANGENT;
                float4 texcoord1 : TEXCOORD1;
                float4 texcoord : TEXCOORD0;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput {
                float4 clipPos : SV_POSITION;
                float4 lightmapUVOrVertexSH : TEXCOORD0;
                half4 fogFactorAndVertexLight : TEXCOORD1;
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    float4 shadowCoord : TEXCOORD2;
                #endif
                float4 tSpace0 : TEXCOORD3;
                float4 tSpace1 : TEXCOORD4;
                float4 tSpace2 : TEXCOORD5;
                #if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
                    float4 screenPos : TEXCOORD6;
                #endif
                float4 ase_texcoord7 : TEXCOORD7;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
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
            #ifdef _TRANSMISSION_ASE
                float _TransmissionShadow;
            #endif
            #ifdef _TRANSLUCENCY_ASE
                float _TransStrength;
                float _TransNormal;
                float _TransScattering;
                float _TransDirect;
                float _TransAmbient;
                float _TransShadow;
            #endif
            #ifdef TESSELLATION_ON
                float _TessPhongStrength;
                float _TessValue;
                float _TessMin;
                float _TessMax;
                float _TessEdgeLength;
                float _TessMaxDisp;
            #endif
            CBUFFER_END
            uniform float4 _CameraDepthTexture_TexelSize;
            sampler2D _RipplesNormal;
            sampler2D _RipplesNormal2;


            float3 mod2D289(float3 x) {
                return x - floor(x * (1.0 / 289.0)) * 289.0;
            }
            float2 mod2D289(float2 x) {
                return x - floor(x * (1.0 / 289.0)) * 289.0;
            }
            float3 permute(float3 x) {
                return mod2D289(((x * 34.0) + 1.0) * x);
            }
            float snoise(float2 v) {
                const float4 C = float4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
                float2 i = floor(v + dot(v, C.yy));
                float2 x0 = v - i + dot(i, C.xx);
                float2 i1;
                i1 = (x0.x > x0.y) ?  float2(1.0, 0.0) : float2(0.0, 1.0);
                float4 x12 = x0.xyxy + C.xxzz;
                x12.xy -= i1;
                i = mod2D289(i);
                float3 p = permute(permute(i.y + float3(0.0, i1.y, 1.0)) + i.x + float3(0.0, i1.x, 1.0));
                float3 m = max(0.5 - float3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
                m = m * m;
                m = m * m;
                float3 x = 2.0 * frac(p * C.www) - 1.0;
                float3 h = abs(x) - 0.5;
                float3 ox = floor(x + 0.5);
                float3 a0 = x - ox;
                m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
                float3 g;
                g.x = a0.x * x0.x + h.x * x0.y;
                g.yz = a0.yz * x12.xz + h.yz * x12.yw;
                return 130.0 * dot(m, g);
            }
            
            inline float4 ASE_ComputeGrabScreenPos(float4 pos) {
                #if UNITY_UV_STARTS_AT_TOP
                    float scale = -1.0;
                #else
                    float scale = 1.0;
                #endif
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
                float4 j = p - 49.0 * floor(p / 49.0);  // mod(p,7*7)
                float4 x_ = floor(j / 7.0);
                float4 y_ = floor(j - 7.0 * x_);  // mod(j,N)
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
            
            float2 voronoihash110(float2 p) {
                
                p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
                return frac(sin(p) * 43758.5453);
            }
            
            float voronoi110(float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId) {
                float2 n = floor(v);
                float2 f = frac(v);
                float F1 = 8.0;
                float F2 = 8.0; float2 mg = 0;
                for (int j = -2; j <= 2; j++) {
                    for (int i = -2; i <= 2; i++) {
                        float2 g = float2(i, j);
                        float2 o = voronoihash110(n + g);
                        o = (sin(time + o * 6.2831) * 0.5 + 0.5); float2 r = f - g - o;
                        float d = 0.5 * dot(r, r);
                        if (d < F1) {
                            F2 = F1;
                            F1 = d; mg = g; mr = r; id = o;
                        } else if (d < F2) {
                            F2 = d;
                        }
                    }
                }
                return (F2 + F1) * 0.5;
            }
            

            VertexOutput VertexFunction(VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.ase_texcoord7.xy = v.texcoord.xy;
                
                o.ase_texcoord7.zw = 0;

                v.ase_normal = v.ase_normal;

                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 positionVS = TransformWorldToView(positionWS);
                float4 positionCS = TransformWorldToHClip(positionWS);

                VertexNormalInputs normalInput = GetVertexNormalInputs(v.ase_normal, v.ase_tangent);

                o.tSpace0 = float4(normalInput.normalWS, positionWS.x);
                o.tSpace1 = float4(normalInput.tangentWS, positionWS.y);
                o.tSpace2 = float4(normalInput.bitangentWS, positionWS.z);

                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
                OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);

                #if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
                    o.lightmapUVOrVertexSH.zw = v.texcoord;
                    o.lightmapUVOrVertexSH.xy = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
                #endif

                half3 vertexLight = VertexLighting(positionWS, normalInput.normalWS);
                #ifdef ASE_FOG
                    half fogFactor = ComputeFogFactor(positionCS.z);
                #else
                    half fogFactor = 0;
                #endif
                o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
                
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    VertexPositionInputs vertexInput = (VertexPositionInputs)0;
                    vertexInput.positionWS = positionWS;
                    vertexInput.positionCS = positionCS;
                    o.shadowCoord = GetShadowCoord(vertexInput);
                #endif
                
                o.clipPos = positionCS;
                #if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
                    o.screenPos = ComputeScreenPos(positionCS);
                #endif
                return o;
            }

            VertexOutput vert(VertexInput v) {
                return VertexFunction(v);
            }


            half4 frag(VertexOutput IN) : SV_Target {
                UNITY_SETUP_INSTANCE_ID(IN);

                #if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
                    float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
                    float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
                    float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
                    float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
                #else
                    float3 WorldNormal = normalize(IN.tSpace0.xyz);
                    float3 WorldTangent = IN.tSpace1.xyz;
                    float3 WorldBiTangent = IN.tSpace2.xyz;
                #endif
                float3 WorldPosition = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
                float3 WorldViewDirection = _WorldSpaceCameraPos.xyz - WorldPosition;
                float4 ShadowCoords = float4(0, 0, 0, 0);
                #if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
                    float4 ScreenPos = IN.screenPos;
                #endif

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    ShadowCoords = IN.shadowCoord;
                #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                    ShadowCoords = TransformWorldToShadowCoord(WorldPosition);
                #endif
                
                WorldViewDirection = SafeNormalize(WorldViewDirection);

                float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
                float screenDepth170 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(ase_screenPosNorm.xy), _ZBufferParams);
                float distanceDepth170 = abs((screenDepth170 - LinearEyeDepth(ase_screenPosNorm.z, _ZBufferParams)) / (_Depth));
                float temp_output_99_0 = pow(distanceDepth170, _OverallFalloff);
                float temp_output_235_0 = (temp_output_99_0 + _ShallowFalloff);
                float4 lerpResult115 = lerp(_ShallowColour, _DeepColour, temp_output_235_0);
                float4 lerpResult177 = lerp(_DeepColour, _VeryDeepColour, saturate((temp_output_99_0 - 1.0)));
                float4 temp_output_175_0 = (temp_output_235_0 < 1.0 ?  lerpResult115 : lerpResult177);
                float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos(ScreenPos);
                float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
                float4 fetchOpaqueVal100 = float4(SHADERGRAPH_SAMPLE_SCENE_COLOR(((ase_grabScreenPosNorm).xy)), 1.0);
                float4 Refraction107 = fetchOpaqueVal100;
                float4 lerpResult121 = lerp(temp_output_175_0, Refraction107, temp_output_175_0);
                float2 temp_output_14_0 = (WorldPosition).xz;
                float2 panner166 = (0.1 * _Time.y * float2(1, 0) + temp_output_14_0);
                float simplePerlin3D44 = snoise(float3((panner166 * 1.5), 0.0));
                float2 panner22 = (0.1 * _Time.y * float2(-1, 0) + temp_output_14_0);
                float simplePerlin3D43 = snoise(float3((panner22 * 3), 0.0));
                float2 texCoord26 = IN.ase_texcoord7.xy * float2(1, 1) + float2(0, 0);
                float2 panner37 = (1.0 * _Time.y * float2(-0.01, 0.01) + texCoord26);
                float foam62 = (saturate(pow((distanceDepth170 + _FoamShoreline), _FoamFalloff)) );
                float4 foamNoise114 = saturate(((_FoamColor * (1.0 - step((simplePerlin3D44 + simplePerlin3D43), (distanceDepth170 * _FoamSpread)))) + (_FoamColor * foam62)));
                float4 lerpResult141 = lerp(lerpResult121, float4(1, 1, 1, 0), foamNoise114);
                float4 waterAlbedo155 = (lerpResult141);
                
                float2 temp_cast_12 = (_RippleSpeed).xx;
                float2 appendResult93 = (float2(WorldPosition.x, WorldPosition.z));
                float2 panner119 = (1.0 * _Time.y * temp_cast_12 + (appendResult93 * _NormalTiling));
                float2 temp_cast_14 = (-_RippleSpeed).xx;
                float2 panner118 = (1.0 * _Time.y * temp_cast_14 + (appendResult93 * _NormalTiling2));
                float3 unpack151 = UnpackNormalScale(float4(BlendNormal(tex2D(_RipplesNormal, panner119).rgb, UnpackNormalScale(tex2D(_RipplesNormal2, panner118), 1.0f)), 0.0), _NormalScale);
                unpack151.z = lerp(1, unpack151.z, saturate(_NormalScale));
                float3 waveNormalMaps157 = unpack151;
                
                float lerpResult147 = _Specular;
                float specular154 = lerpResult147;
                float3 temp_cast_17 = (specular154).xxx;
                
                float lerpResult132 =_Smoothness;
                float smoothness156 = (lerpResult132 * _ReflectionPower);
                
                float screenDepth234 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(ase_screenPosNorm.xy), _ZBufferParams);
                float distanceDepth234 = abs(screenDepth234 - LinearEyeDepth(ase_screenPosNorm.z, _ZBufferParams));
                float waterOpacity218 = (_OpacityMin + saturate(distanceDepth234 / _OpacityFalloff) * (1- _OpacityMin) ) * _Opacity;
                
                float3 Albedo = waterAlbedo155.rgb;
                float3 Normal = waveNormalMaps157;
                float3 Emission =half4(0,0,0,0); 
                float3 Specular = temp_cast_17;
                float Metallic = 0;
                float Smoothness = smoothness156;
                float Occlusion = 1;
                float Alpha = waterOpacity218;

                InputData inputData;
                inputData.positionWS = WorldPosition;
                inputData.viewDirectionWS = WorldViewDirection;
                inputData.shadowCoord = ShadowCoords;

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

                return color;
            }

            ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
    Fallback "Standard"
}