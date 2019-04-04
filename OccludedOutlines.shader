Shader "VP/OccludedOutlines"
{
    Properties
    {
        _Tint ("Tint", Color) = (0,0,0,0)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _OutlineColor ("Outline Color", Color) = (1,1,1,1)
        _OutlineThickness("Outline Thickness", Range(0,1)) = 0.5
        _Power ("Fresnel Power", Int) = 2
        _Bias ("Fresnel Bias", Float) = 1.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        LOD 200

        Pass {
            ZWrite Off
            ZTest Always

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct appdata{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f {
                float4 vertex  : SV_POSITION;
                float3 normal  : NORMAL;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                return o;
            }

            float4 _OutlineColor;
            half _OutlineThickness, _Power, _Bias;

            fixed4 frag(v2f IN) : SV_Target
            {
                float4 c = _OutlineColor;
                //o.R = _Bias + _Scale * pow(1.0 + dot(I, normWorld), _Power);
                half rim = saturate( dot(normalize(IN.viewDir), IN.normal) );
                if (rim > _OutlineThickness) discard;
                return c;
            }

            ENDCG    
        }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Tint;
        half _Glossiness;
        half _Metallic;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Tint;
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
