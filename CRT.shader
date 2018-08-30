Shader "Custom/CRT" {

    Properties{
        _MainTex ("Texture", 2D) = "white" {}
        _PixelTex ("Pixel texture", 2D) = "white" {}
        _GlassTex ("Glass texture", 2D) = "white" {}
        _PixelDensity ("Pixel Density", Float) = 10.0
        _BackLight ("Pixel backlight", Range(0,10)) = 5
        _Static ("Static noise", Range(0,0.25)) = 0.01
        _Distort ("Distortion Amount", Range(0,0.1)) = 0.01
        _DistortNar ("Distortion Narrowness (x2)", Range(1,10)) = 5.0
        _DistortSpd ("Distortion Speed", Range(1,10)) = 5.0
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
            fixed _BackLight, _Static, _Distort, _DistortNar, _DistortSpd;

            v2f vert(appdata v) {

                v2f o;
                
                o.uv_MainTex = v.uv_MainTex;
                o.uv_PixelTex.xy = v.uv_MainTex * _PixelDensity;
                o.uv_PixelTex.x -= _PixelDensity/3.0;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.pos.x += _Distort * exp(-pow(_CosTime.z*_DistortSpd - o.pos.y, 2) / 2*pow(_DistortNar,2));
                //o.pos.x += _Distort * sin( _Time.z*_DistortNar*o.pos.y );

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
            fixed _BackLight, _Static, _Distort, _DistortNar, _DistortSpd;

            v2f vert(appdata v) {

                v2f o;
                
                o.uv_MainTex = v.uv_MainTex;
                o.uv_PixelTex.xy = v.uv_MainTex * _PixelDensity;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.pos.x += _Distort * exp(-pow(_CosTime.z/_SinTime.x*_DistortSpd - o.pos.y, 2) / 2*pow(_DistortNar,2));

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
            fixed _BackLight, _Static, _Distort, _DistortSpd, _DistortNar;

            v2f vert(appdata v) {

                v2f o;
                
                o.uv_MainTex = v.uv_MainTex;
                o.uv_PixelTex.xy = v.uv_MainTex * _PixelDensity;
                o.uv_PixelTex.x += _PixelDensity/3.0;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.pos.x += _Distort * exp(-pow(_SinTime.z*_DistortSpd - o.pos.y, 2) / 2*pow(_DistortNar,2));

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

        // Glass
        CGPROGRAM
        #include "UnityCG.cginc"

        #pragma surface surf Standard fullforwardshadows alpha:blend
        #pragma target 3.0

        sampler2D _GlassTex;
        struct Input {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o) {

            fixed4 c = tex2D (_GlassTex, IN.uv_MainTex);

            o.Albedo = fixed3(1.0,1.0,1.0);
            o.Alpha = c.a + 0.1;
            o.Emission = c;
            o.Metallic = 0.0;
            o.Smoothness = 1.0;
        }
        ENDCG
    }
    Fallback "Diffuse"
}