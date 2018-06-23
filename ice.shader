Shader "Custom/Ice" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_MainNormalMap("Normal Map", 2D) = "white" {}		
		_DistortTex("Refraction", 2D) = "white" {}
		_CrackTex("Cracks", 2D) = "white" {}
		_CrackNorm("Cracks Normal Map", 2D) = "white" {}
		_CrackVisibility("Cracks visibility", Range(0,1)) = 0.0
		_NumCracks("Number of Cracks", Int) = 0
		_Color ("Emission color", Color) = (1,1,1,1)
		_EmissionAmount ("Emission Amount", Range(0,2)) = 0.75
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_TexAlpha ("Visibilidad Textura", Range(0,1)) = 0.5
	}
	SubShader {
		Tags { "Queue"="Overlay" "RenderType"="Transparent"  }
		LOD 200

		// 1a pasada: renderiza su background como textura
		GrabPass {}

		Zwrite off
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows alpha:fade
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MainNormalMap;
		sampler2D _GrabTexture;	// Textura renderizada a partir de lo que tiene detrás
		sampler2D _DistortTex;
		sampler2D _CrackTex;
		sampler2D _CrackNorm;
		fixed _CrackVisibility;
		float _EmissionAmount;
		int _NumCracks;

		struct Input {
			float2 uv_MainTex;
			float2 uv_DistortTex;
			float2 uv_CrackTex;
			float4 screenPos;
			float3 viewDir;
			//float3 N : NORMAL;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		fixed _TexAlpha;

		float4 _GrabTexture_TexelSize;

		void surf (Input IN, inout SurfaceOutputStandard o) {	

			fixed4 c = (0,0,0,0);	
			float3 N = UnpackNormal(tex2D(_MainNormalMap, IN.uv_MainTex));

			float anguloVision = dot(IN.viewDir, N);
			o.Emission = _Color.xyz * (anguloVision) * _EmissionAmount;
			
			// Determinar el grado de distorsión a partir de la textura
			float3 distortAmount = tex2D(_DistortTex, IN.uv_DistortTex).xyz;
			for (int i=1; i<_NumCracks+1; i++) {
				float2 newUV = IN.uv_CrackTex;
				newUV *= i;
				distortAmount += tex2D(_CrackTex, newUV).xyz * _CrackVisibility;
				c += tex2D(_CrackTex, newUV) * 1.5 * _CrackVisibility;
				N += UnpackNormal(tex2D(_CrackNorm, newUV));
			}
			
			IN.screenPos.xy = distortAmount.xy * _GrabTexture_TexelSize.xy * 500 * IN.screenPos.z + IN.screenPos.xy; // Fórmula del usuario rocket350 de los foros de Unity

			c += tex2Dproj(_GrabTexture, IN.screenPos) * (1-_TexAlpha) + tex2D(_MainTex, IN.uv_MainTex) * _TexAlpha;
			o.Albedo = c.rgb;
			o.Normal = N;
            o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			
			// La transparencia la simulamos con la textura, asi que el Alpha debe ser 1
			o.Alpha = 1.0;
		}
		ENDCG
	}
	FallBack "Diffuse"
}