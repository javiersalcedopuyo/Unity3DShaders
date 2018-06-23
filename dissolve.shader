Shader "Brackeys/Dissolve" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_EmissiveColor ("Emission Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_AlphaThres ("Alpha threshold", Range(0,1)) = 0.5
		_NoiseScale("Noise Scale", Range(0,10)) = 3
		_BorderWidth("Emissive Border Width", Range(0,0.1)) = 0.01
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "Queue"="Overlay" "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#include "inc/simpleNoise.cginc"
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color, _EmissiveColor;
		float _AlphaThres, _BorderWidth, _NoiseScale;

		void surf (Input IN, inout SurfaceOutputStandard o) {

			_AlphaThres = (_SinTime.z);
			// Albedo comes from a texture tinted by color
			float a = saturate(simpleNoise(_NoiseScale*10, IN.uv_MainTex));
			clip(a - _AlphaThres);	// Discard when alpha is less than the threshold

			float b = step(a, _AlphaThres+_BorderWidth);
			//o.Emission = b * _EmissiveColor;

			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb + b*_EmissiveColor;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Emission += b*_EmissiveColor;
			o.Alpha = 1.0;
			//o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
