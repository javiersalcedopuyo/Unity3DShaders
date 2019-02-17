fixed rand(fixed2 coord){
    return frac(sin(dot(coord, fixed2(56, 78)) * 1000.0) * 1000.0);
}

fixed noise(fixed2 coord)
{
    fixed2 i = floor(coord);
    fixed2 f = frac(coord);

    // 4 corners of a rectangle surrounding our point
    fixed a = rand(i);
    fixed b = rand(i + fixed2(1.0, 0.0));
    fixed c = rand(i + fixed2(0.0, 1.0));
    fixed d = rand(i + fixed2(1.0, 1.0));

    fixed2 cubic = f * f * (3.0 - 2.0 * f);

    return lerp(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

fixed fbm(fixed2 coord, int octaves=4)
{
    fixed value = 0.0;
    fixed scale = 0.5;

    for(int i = 0; i < octaves; i++) {
        value += noise(coord) * scale;
        coord *= 2.0;
        scale *= 0.5;
    }
    return value;
}