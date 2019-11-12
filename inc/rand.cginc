fixed rand (fixed2 coord)
{
    return frac(sin(dot(coord, fixed2(56, 78)) * 1000.0) * 1000.0);
}

fixed2 rand2 (fixed2 p)
{
  return frac(sin(fixed2(dot(p, fixed2(127.1,311.7)), dot(p, fixed2(269.5, 183.3)))) * 43758.5453);
}