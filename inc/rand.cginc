#ifndef RAND_CGINC
#define RAND_CGINC

fixed rand (in fixed2 coord)
{
    return frac(sin(dot(coord, fixed2(56, 78)) * 1000.0) * 1000.0);
}

fixed2 rand2 (in fixed2 p)
{
  return frac(sin(fixed2(dot(p, fixed2(127.1,311.7)), dot(p, fixed2(269.5, 183.3)))) * 43758.5453);
}

fixed2 rand  (in fixed a, in fixed b) { return rand(fixed2(a,b)); }
fixed2 rand2 (in fixed a, in fixed b) { return rand2(fixed2(a,b)); }

#endif
