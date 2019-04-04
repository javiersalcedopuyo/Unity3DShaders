// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "Custom/shockwave" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		// Shockwave params
		_WaveSize ("Max Wave Size", Float) = 2.0
		_WaveWidth ("Wave Width", Float) = 1.0
		_WaveSpeed ("Wave's speed of propagation", Float) = 3.0
		_StartTime ("Time of shock", Vector) = (0,0,0,0)
		_StartPoint ("Shockwave Centre", Vector) = (0,0,0)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		float4 _StartTime;
		float3 _StartPoint;
		float _WaveSize;
		float _WaveWidth;
		float _WaveSpeed;

		// Vertex Shader
		void vert(inout appdata_full v, out Input i) {

			UNITY_INITIALIZE_OUTPUT(Input,i);
			
			//float radius = distance(v.vertex.xy, _StartPoint.xy);	// Para modelos de blender
			float radius = distance(v.vertex.xz, _StartPoint.xz);	// Para modelos de unity
			float timePassed = (_Time.w - _StartTime.w) * _WaveSpeed;
			float jump;
			float offset = 1.45;	// Distance between both Gaussian Waves (3 times the 2nd one's standard deviation)

			jump = _WaveSize * exp(-pow(timePassed - radius, 2) / 2*pow(_WaveWidth, 2)) / (radius+0.05);	// Gaussian Wave + amp reduction with distance
			jump *= exp(-pow(timePassed - (radius - offset), 2) / 2*pow(offset/3, 2)) / 10*(radius+0.05);	// Second Gaussian curve of height 1 to avoid spikes near the origin	

			//v.vertex.z += jump; // For Blender meshes
			v.vertex.y += jump; // For Unity meshes
		}

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		// Surface shader
		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
