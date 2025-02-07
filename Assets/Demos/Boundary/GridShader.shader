Shader "Custom/GridDistortion" {
    Properties {
        _GridColor ("Grid Color", Color) = (1,1,1,1)
        _LineWidth ("Line Width", Range(0, 0.1)) = 0.02
        _DistortAmp ("Distortion Amplitude", Range(0,1)) = 0.1
        _DistortFreq ("Distortion Frequency", Float) = 5
        _DistortSpeed ("Distortion Speed", Float) = 1
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc" 

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float _LineWidth;
            fixed4 _GridColor;
            float _DistortAmp;
            float _DistortFreq;
            float _DistortSpeed;

            v2f vert (appdata v) {
                v2f o;
                o.vertex  = UnityObjectToClipPos(v.vertex); 
                o.uv  = v.uv; 
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                // 添加随机噪声扰动
                float2 noise = float2(
                    sin(i.uv.y  * _DistortFreq + _Time.y * _DistortSpeed) * 0.5 + 0.5,
                    cos(i.uv.x  * _DistortFreq * 1.3 + _Time.y * _DistortSpeed * 0.7) * 0.5 + 0.5
                );

                // 应用UV偏移
                float2 distortedUV = i.uv  + noise * _DistortAmp * 0.05;

                // 绘制网格逻辑
                float2 grid = abs(frac(distortedUV) - 0.5);
                float lines = min(
                    step(_LineWidth, grid.x) * step(_LineWidth, grid.y),
                    step(length(grid), _LineWidth * 1.42)
                );
                
                return lerp(_GridColor, fixed4(0,0,0,1), lines);
            }
            ENDCG
        }
    }
}