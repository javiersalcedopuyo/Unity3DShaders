Shader "Custom/aura" {
	Properties {
		_BaseColor("Aura Base Color", Color) = (1,1,0,1)
		_SecondColor("Aura Secondary Color", Color) = (1,1,0,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Offset ("Aura distance", Float) = 0.1
		_NoiseScale ("Noise Scale", Range(0,0.2)) = 0.01
		_NoiseSpeedX ("Noise X speed", Float) = 1.0
		_NoiseSpeedY ("Noise Y speed", Float) = 1.0
		_RimPower("Rim Power", Range(0.01, 10.0)) = 1
		_Brightness("Brightness", Range(0.5, 3)) = 2
		_Opacity ("Opacity", Range(0,10)) = 1.0
		_Edge("2nd Rim Size", Range(0,10)) = 0.1
	}
	SubShader {
		Tags { "Queue"="Overlay" "RenderType"="Transparent"  }
		LOD 200

		// 1st Pass: Render the Aura itself
		Pass{

			Name "Aura"
			Cull Back
			ZWrite Off
			ColorMask RGB

			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#include "UnityCG.cginc"
			#include "inc/simpleNoise.cginc"		
			//#pragma surface surf Standard fullforwardshadows alpha:blend
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			sampler2D _MainTex;
			sampler2D _NoiseTex;		

			struct Input {
				float4 pos;
				float2 uv_MainTex;
				float3 viewDir;
				float3 localPos;
			};
			struct appdata {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uvText : TEXCOORD0;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv_Tex : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
			};

			fixed4 _BaseColor;
			fixed4 _SecondColor;
			float _Offset;
			float _NoiseScale;
			float _NoiseSpeedX, _NoiseSpeedY, _RimPower, _Opacity, _Edge, _Brightness;

			v2f vert(appdata iov) {

				v2f o;
				o.pos = UnityObjectToClipPos(iov.vertex);

				// Displace the vertex an offset amount in the direction of the screen-space normal
				float3 norm  = normalize(mul ((float3x3)UNITY_MATRIX_IT_MV, iov.normal));
				float2 offsetDir = TransformViewToProjection(norm.xy);
				o.pos.xy += offsetDir * _Offset;

				o.normalDir = normalize(mul(float4(iov.normal, 0), unity_WorldToObject).xyz);
				o.viewDir = normalize(WorldSpaceViewDir(iov.vertex));
				o.uv_Tex = iov.uvText;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {

				// Get the noise value to substract it from the aura, displacing the UV depending of the position of the fragment
				float2 uvNoise = float2(i.pos.x* _NoiseScale - (_Time.x * _NoiseSpeedX), i.pos.y * _NoiseScale - (_Time.x * _NoiseSpeedY));
				half n = simpleNoise(30.0, uvNoise);
				fixed4 noise = fixed4(n,n,n,n);

				// Use the normals and view direction to compute the rims
				float viewAngle = saturate(dot(i.viewDir, i.normalDir));	// Saturate = clamp between 0 and 1
				float4 rim = pow(viewAngle, _RimPower) - noise;
				float4 baseRim  = saturate(rim.a*_Opacity);
				float4 extraRim = (saturate((_Edge + rim.a)*_Opacity) - baseRim) * _Brightness;
				// Combine both and set the alpha depending of the view angle
				fixed4 aura = _BaseColor*baseRim + _SecondColor*extraRim;
				aura.a *= viewAngle + 0.25;
				return aura;
			}
			ENDCG
		} // End of 1st pass
				
		// 2nd PASS
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutputStandard o) {

			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
		}
		ENDCG
		// End of 2nd Pass
	}
	FallBack "Diffuse"
}
