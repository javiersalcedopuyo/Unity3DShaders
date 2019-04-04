Shader "Custom/Emmental"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _CenterX ("X", Range(0,1)) = 0.5
        _CenterY ("Y", Range(0,1)) = 0.5
        _Radius  ("R", Range(0,1)) = 0.5
    }
    
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha:blend
        #pragma target 3.0

        uniform float _CentersX[10];
        uniform float _CentersY[10];
        uniform float _RadiusArray[10];

        sampler2D _MainTex;
        float _CenterX, _CenterY, _Radius;

        struct Input
        {
            float2 uv_MainTex;
        };

        float isInHole(float2 fragUV)
        {
            float x = fragUV.x;
            float y = fragUV.y;

            float a, b, r; // Circle properties
            float fR;      // Needed radius for the fragment to be inside the circle

            for (int i=0; i<10; i++)
            {
                a = _CentersX[i];
                b = _CentersY[i];
                r = _RadiusArray[i];

                fR = sqrt( (x-a)*(x-a) + (y-b)*(y-b) );
                if (fR < r) return 0.0;
            }
            return 1.0;
        }

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = isInHole(IN.uv_MainTex);
        }
        ENDCG
    }
    Fallback "Transparent/VertexLit"
}
