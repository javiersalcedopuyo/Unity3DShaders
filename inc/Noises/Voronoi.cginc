#include "../rand.cginc"

fixed VoronoiNoise(in fixed2 uv, in fixed speed)
{
  fixed  minDist = 1.0;
  fixed  dist;
  fixed2 neighborOffset;
  fixed2 neighborPoint;
  // Get the distance to the nearest point in the 3x3 tile neighborhood
  for (int y=-1; y<=1; y++) {
    for (int x=-1; x<=1; x++)
    {
      neighborOffset = fixed2(fixed(x), fixed(y));
      neighborPoint  = rand2(floor(uv) + neighborOffset);
      // Move the point
      neighborPoint = 0.5 + 0.5 * sin(speed*_Time.y + 6.2831*neighborPoint);
      dist     = length(neighborOffset + neighborPoint - frac(uv));

      minDist  = min(minDist, dist);
    }
  }
  return minDist;             
}