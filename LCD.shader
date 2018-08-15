Shader "Custom/LCD" {

    Properties{
        _MainTex ("Texture", 2D) = "white" {}
        _PixelTex ("Pixel texture", 2D) = "white" {}
        _PixelDensity ("Pixel Density", Float) = 10.0
        _BackLight ("Pixel backlight", Range(0,10)) = 5
        _Static ("Static noise", Range(0,0.25)) = 0.01
        _Distort ("Distortion Amount", Range(0,0.25)) = 0.1
    }

    SubShader {
        Tags {"Queue"="Overlay" "RenderType"="Transparent"}
        LOD 200

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        // RED
        Pass {

            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag
            #pragma multi_compile_fog   // Enable fog

            #include "UnityCG.cginc"
            #include "inc/simpleNoise.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_PixelTex : TEXCOORD1;
                float4 normal : NORMAL;
            };

            struct v2f {
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_PixelTex : TEXCOORD1;
                float4 pos : SV_POSITION;
                float4 normal : NORMAL;
            };

            sampler2D _MainTex;
            sampler2D _PixelTex;
            int _PixelDensity; 
            fixed _BackLight, _Static, _Distort, _Freq;

            v2f vert(appdata v) {

                v2f o;
                
                o.uv_MainTex = v.uv_MainTex;
                o.uv_PixelTex.xy = v.uv_MainTex * _PixelDensity;
                o.uv_PixelTex.x += _PixelDensity/3.0;

                // Transform the normal from object space to view space
				float3 viewNorm  = normalize(mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal));
                // Get the direction of the displacement (we'll only use the Xs in projection space)
                float2 distorDir = TransformViewToProjection(viewNorm.xy);
                // Displace the vertex
                v.vertex.x += distorDir.x * _Distort * sin(_Time.z*5) *v.vertex.y;

                o.pos = UnityObjectToClipPos(v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target {

                clip(rand(i.uv_MainTex*_Time.z) - _Static);

                fixed4 c1 = tex2D(_MainTex, i.uv_MainTex);
                fixed4 c2 = tex2D(_PixelTex, i.uv_PixelTex);
                fixed4 c = c1*c2.rgba * _BackLight;
                c.a = c2.a;
                c.yz = 0.0;
                return c;
            }
            ENDCG
        }

        // GREEN
        Pass {

            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag
            #pragma multi_compile_fog   // Enable fog

            #include "UnityCG.cginc"
            #include "inc/simpleNoise.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_PixelTex : TEXCOORD1;
                float4 normal : NORMAL;
            };

            struct v2f {
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_PixelTex : TEXCOORD1;
                float4 pos : SV_POSITION;
                float4 normal : NORMAL;
            };

            sampler2D _MainTex;
            sampler2D _PixelTex;
            int _PixelDensity; 
            fixed _BackLight, _Static, _Distort, _Freq;

            v2f vert(appdata v) {

                v2f o;
                
                o.uv_MainTex = v.uv_MainTex;
                o.uv_PixelTex.xy = v.uv_MainTex * _PixelDensity;

                // Transform the normal from object space to view space
				float3 viewNorm  = normalize(mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal));
                // Get the direction of the displacement (we'll only use the Xs in projection space)
                float2 distorDir = TransformViewToProjection(viewNorm.xy);
                // Displace the vertex
                v.vertex.x += distorDir.x * _Distort * sin(_Time.z*5 + 45.0) *v.vertex.y;

                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {

                clip(rand(i.uv_MainTex*_Time.z) - _Static);

                fixed4 c1 = tex2D(_MainTex, i.uv_MainTex);
                fixed4 c2 = tex2D(_PixelTex, i.uv_PixelTex);
                fixed4 c = c1*c2.rgba * _BackLight;
                c.a = c2.a;
                c.xz = 0.0;
                return c;
            }
            ENDCG
        }

        // BLUE
        Pass {

            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag
            #pragma multi_compile_fog   // Enable fog

            #include "UnityCG.cginc"
            #include "inc/simpleNoise.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_PixelTex : TEXCOORD1;
                float4 normal : NORMAL;
            };

            struct v2f {
                float2 uv_MainTex : TEXCOORD0;
                float2 uv_PixelTex : TEXCOORD1;
                float4 pos : SV_POSITION;
                float4 normal : NORMAL;
            };

            sampler2D _MainTex;
            sampler2D _PixelTex;
            int _PixelDensity; 
            fixed _BackLight, _Static, _Distort, _Freq;

            v2f vert(appdata v) {

                v2f o;
                
                o.uv_MainTex = v.uv_MainTex;
                o.uv_PixelTex.xy = v.uv_MainTex * _PixelDensity;
                o.uv_PixelTex.x -= _PixelDensity/3.0;

                // Transform the normal from object space to view space
				float3 viewNorm  = normalize(mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal));
                // Get the direction of the displacement (we'll only use the Xs in projection space)
                float2 distorDir = TransformViewToProjection(viewNorm.xy);
                // Displace the vertex
                v.vertex.x += distorDir.x * _Distort * sin(_Time.z*5 + 90.0) *v.vertex.y;

                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {

                clip(rand(i.uv_MainTex*_Time.z) - _Static);

                fixed4 c1 = tex2D(_MainTex, i.uv_MainTex);
                fixed4 c2 = tex2D(_PixelTex, i.uv_PixelTex);
                fixed4 c = c1*c2.rgba * _BackLight;
                c.a = c2.a ;
                c.xy = 0.0;
                return c;
            }
            ENDCG
        }
    }

}