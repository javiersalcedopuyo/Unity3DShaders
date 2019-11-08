Shader "Custom/ParallaxOcclussion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "white" {}
        _DepthMap ("Depth Map", 2D) = "white" {}
        _DepthMul ("Depth Multiplier", Range(0,0.5)) = 0.1
        _NumLayersMin ("Min Number of Layers", Int) = 8
        _NumLayersMax ("Max Number of Layers", Int) = 64
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma target 3.0

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 tanViewDir : TEXCOORD2;
            };

            int       _NumLayersMin, _NumLayersMax;
            half      _DepthMul;
            float4    _MainTex_ST;
            sampler2D _MainTex, _NormalMap, _DepthMap;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                const float3 bitangent = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                // TBN matrix form World Space
                const fixed3 T = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz,0.0))).xyz;
                const fixed3 B = normalize(mul(unity_ObjectToWorld, float4(bitangent, 0.0))).xyz;
                const fixed3 N = normalize(mul(unity_ObjectToWorld, float4(v.normal,0.0))).xyz;
                //const fixed3 B = normalize(cross(N,T));
                const fixed3x3 TBN = transpose(fixed3x3(T,B,N));

                const fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                const fixed3 worldViewDir = normalize(_WorldSpaceCameraPos - worldPos);
                o.tanViewDir = normalize(mul(TBN, float4(worldViewDir, 0.0))).xyz;

                o.lightDir = -normalize(_WorldSpaceLightPos0).xyz;

                return o;
            }

            float2 ParallaxOcclusion(in float2 UVs, in float3 viewDir)
            {
              float2 o = UVs;

              const int numLayers = floor(lerp(_NumLayersMin, _NumLayersMax, viewDir.z));
              const float  deltaDepth  = 1.0 / numLayers;
              const float2 deltaOffset = _DepthMul * viewDir.xy / numLayers;

              float  mapDepth = tex2D(_DepthMap, UVs).r;
              float  currentDepth = 0.0;

              [unroll(32)]while(currentDepth < mapDepth)
              {
                o -= deltaOffset;
                currentDepth += deltaDepth;
                mapDepth = tex2D(_DepthMap, o).r;
              }

              const float2 prevUVs = o + deltaOffset;
              const float  nextDepth = mapDepth - currentDepth;
              const float  prevDepth = tex2D(_DepthMap, prevUVs).r - currentDepth + deltaDepth;
              const float  w = nextDepth / (nextDepth - prevDepth);

              o = prevUVs * w + o * (1-w);

              return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 newUVs = ParallaxOcclusion(i.uv, i.tanViewDir);
                if (newUVs.x > 1.0 || newUVs.x < 0.0 ||
                    newUVs.y > 1.0 || newUVs.y < 0.0)
                {
                  discard;
                }

                fixed3 normal = UnpackNormal(tex2D(_NormalMap, newUVs));
                half lambert = dot(normal, i.lightDir) + 0.1;

                fixed4 col = tex2D(_MainTex, newUVs) * saturate(lambert);

                return col;
            }
            ENDCG
        }
    }
}
