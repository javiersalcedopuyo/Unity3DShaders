Shader "Custom/Water" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_DistortTex("Refraction Pattern", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_DistortAmount ("Distortion", Range(0.1,5)) = 1
		_WaterAlpha ("Claridad", Range(0,1)) = 0.75
		_TexAlpha ("Visibilidad Textura", Range(0,1)) = 0.5
	}
	SubShader {
		Tags { "Queue"="Overlay" "RenderType"="Transparent"  }
		LOD 200
		Zwrite off

		// 1st pass: Renders background as texture
		GrabPass {
		}

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows alpha:fade
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		#include "inc/simpleNoise.cginc"

		sampler2D _MainTex;
		sampler2D _GrabTexture;	// Textura renderizada a partir de lo que tiene detrás
		sampler2D _DistortTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_DistortTex;
			float4 screenPos;
		};

		half _DistortAmount;
		fixed4 _Color;
		fixed _WaterAlpha;
		fixed _TexAlpha;

		float4 _GrabTexture_TexelSize;

		void surf (Input IN, inout SurfaceOutputStandard o) {

			// Movimiento de la refracción
			IN.uv_DistortTex.x *= _SinTime.x;
			IN.uv_DistortTex.y *= _CosTime.x;
			IN.uv_MainTex.x *= _CosTime.x;
			IN.uv_MainTex.y *= _SinTime.x;			

			// Determinar el grado de distorsión a partir de la textura
			float3 distortAmount = tex2D(_DistortTex, IN.uv_DistortTex);
			//float distortAmount = simpleNoise(_DistortAmount, IN.uv_MainTex); 
			IN.screenPos.xy = distortAmount * _GrabTexture_TexelSize.xy * _DistortAmount*100 * IN.screenPos.z + IN.screenPos.xy; // Fórmula del usuario rocket350 de los foros de Unity

			fixed4 c = tex2Dproj(_GrabTexture, IN.screenPos) * (1-_TexAlpha) + tex2D(_MainTex, IN.uv_MainTex) * _Color * _WaterAlpha;
			o.Albedo = c.rgb;

			// La transparencia la simulamos con la textura, asi que el Alpha debe ser 1
			o.Alpha = 1.0;
			o.Metallic = 0.0;
			o.Smoothness = 1.0;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
