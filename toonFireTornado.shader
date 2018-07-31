Shader "Custom/toonFireTornado" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Emission ("Emision Map(RGB)", 2D) = "black" {}
		_EmissionAmount ("Emission Amount", Range(0,3)) = 1.0
		_Tiling ("Texture Uniform Tiling", Float) = 1.0
		_Speed ("Speed", Float) = 10.0
		_Alpha ("Transparency", Range(0,1)) = 1.0
	}
	SubShader {
		
		Tags { "Queue"="Overlay" "RenderType"="Transparent"  }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows alpha:blend
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _Emission;

		struct Input {
			float2 uv_MainTex;
		};

		float _Speed;
		float _Alpha;
		float _Tiling;
		float _EmissionAmount;

		void surf (Input IN, inout SurfaceOutputStandard o) {

			// Tiling de la textura (uniforme en x e y)
			IN.uv_MainTex.y *= _Tiling;
			// Movimiento de cascada
			IN.uv_MainTex.y -= _Time.x * _Speed;
			IN.uv_MainTex.x += _Time.y;

			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Metallic = 0.0;
			o.Smoothness = 0.0;
			o.Emission = tex2D(_Emission, IN.uv_MainTex) * _EmissionAmount;
			o.Alpha = _Alpha;
		}
		ENDCG
	}
	FallBack "Diffuse"
}