// Unity's ShaderGraph SimpleNoise function
float rand (float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
}

float unity_noise_interpolate (float a, float b, float t)
{
    return (1.0-t)*a + (t*b);
}

float unity_valueNoise (float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3.0 - 2.0 * f);

    uv = abs(frac(uv) - 0.5);
    float2 c0 = i + float2(0.0, 0.0);
    float2 c1 = i + float2(1.0, 0.0);
    float2 c2 = i + float2(0.0, 1.0);
    float2 c3 = i + float2(1.0, 1.0);
    float r0 = rand(c0);
    float r1 = rand(c1);
    float r2 = rand(c2);
    float r3 = rand(c3);

    float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
    float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
    float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
    return t;
}
float simpleNoise(float Scale, fixed2 UV) {

    float t = 0.0;
    for(int i = 0; i < 3; i++)
    {
        float freq = pow(2.0, float(i));
        float amp = pow(0.5, float(3-i));
        t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
    }
    return t;
}