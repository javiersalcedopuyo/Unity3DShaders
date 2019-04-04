Shader "VP/GhostShader"
{
    Properties
    {
        _Tint ("Tint", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Alpha ("Base Opacity", Range(0,1)) = 0.5
        _BaseEmission("Base emission", Range(0,10)) = 1.0
        _Octaves ("FBM Octaves", Int) = 4
        _FBias ("Fresnel Bias", Float) = 1.0
        _FPower ("Fresnel Power", Int) = 2
        _FScale ("Fresnel Scale", Float) = 1.0
    }
    SubShader
    {
        Tags {"Queue"="Overlay" "RenderType"="Transparent" }
        LOD 200

        ZWrite Off
        Cull Off

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert alpha:blend
        #pragma target 3.0

        #include "UnityCG.cginc"
        #include "./inc/FractalBrownianMotion.cginc"
            
        struct appdata{
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float2 texUVs : TEXCOORD0;
        };
        struct Input {
            float4 vertex  : SV_POSITION;
            float3 normal  : NORMAL;
            float2 texUVs  : TEXCOORD0;
            float3 viewDir : TEXCOORD2;
        };

        void vert(inout appdata v, out Input o)
        {
            o.vertex  = UnityObjectToClipPos(v.vertex);
            o.normal  = UnityObjectToWorldNormal(v.normal);
            o.viewDir = WorldSpaceViewDir(v.vertex);
            o.texUVs  = v.texUVs;
        }

        sampler2D _MainTex;
        fixed4 _Tint;
        fixed _Glossiness, _Metallic, _Alpha, _BaseEmission, _FBias, _FScale;
        int _Octaves, _FPower;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Moving "smoke"
            IN.texUVs += _Time.x;
            fixed2 coords = IN.texUVs * 20;
            fixed motion1D = fbm(coords + fixed2(_Time.y*0.5, -0.5*_Time.y), _Octaves);
            fixed2 motion = fixed2( motion1D, motion1D );
            fixed final = fbm(coords + motion, _Octaves);

            // Fresnel
            fixed rim = _FBias + _FScale * pow(1.0 + dot(IN.viewDir, IN.normal), _FPower);

            o.Emission = (final * rim + _BaseEmission) * _Tint;
            o.Alpha = saturate( _Alpha + final ) * (1.0 -saturate(rim));
        }
        ENDCG
    }
    FallBack "Diffuse"
}
