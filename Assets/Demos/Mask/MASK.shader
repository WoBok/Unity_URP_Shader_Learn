// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Mask" {
	Properties{
		_MainTex("MainTex",2D) = "white"{}
		_Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5
	}
		SubShader{
			Tags {"Queue" = "Geometry-1" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}

			Pass {
				ColorMask 0
				ZWrite Off

				Stencil
				{
					Ref 1
					Comp Always
					Pass Replace
				}

				Blend SrcAlpha OneMinusSrcAlpha
				//Cull Off

				CGPROGRAM

				#pragma multi_compile_fwdbase

				#pragma vertex vert
				#pragma fragment frag

				#include "Lighting.cginc"
				#include "AutoLight.cginc"

				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed _Cutoff;

				struct a2v {
					float4 vertex : POSITION;
					float4 texcoord : TEXCOORD0;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD2;
				};

				v2f vert(a2v v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target {

					fixed4 texColor = tex2D(_MainTex, i.uv);

					clip(texColor.a - _Cutoff);

					fixed3 albedo = texColor.rgb;

					return fixed4(1,1,1,1);
				}

				ENDCG
			}
		}
			FallBack "Transparent/Cutout/VertexLit"
}
