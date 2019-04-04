Shader "Custom/GrassDisp"
{
    Properties
    {
        _Color1 ("Tint 01", Color) = (1,1,1,1)
        _Color2 ("Tint 02", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Normals ("Normals", 2D) = "white" {}
        _AO ("Ambient Oclussion", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _DisplacementOffset ("Displacement Offset", Float) = 0.0
        [HideInInspector] _ObjPos ("Object Position", Vector) = (0,0,0,0)
        [HideInInspector] _ObjRad ("Object Radius", Float) = 0.0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 200
        Cull Off

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert alpha:fade
        #pragma target 3.0

        half _Glossiness;
        half _Metallic;
        fixed4 _Color1, _Color2;
        sampler2D _MainTex, _Normals, _AO;

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _ObjPos;
        fixed  _ObjRad, _DisplacementOffset;

        void vert ( inout appdata_full v, out Input i )
        {
          UNITY_INITIALIZE_OUTPUT(Input,i);

          fixed4 wVertexPos = mul(unity_ObjectToWorld, v.vertex);
          fixed dist = distance(_ObjPos.xz, wVertexPos.xz);
          if (dist > _ObjRad) return;

          fixed4 displacement = normalize(_ObjPos - wVertexPos) * (_ObjRad - dist) + _DisplacementOffset;
          wVertexPos.xz = lerp(wVertexPos.xz, (wVertexPos-displacement).xz, v.texcoord.y);

          v.vertex = mul(unity_WorldToObject, wVertexPos);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            float2 uv2 = IN.uv_MainTex;
            uv2.y -= 0.02;
            fixed4 c = tex2D (_MainTex, uv2) * lerp(_Color1, _Color2, IN.uv_MainTex.y);
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a * (1.0);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
