#ifndef VORONOI_CGINC
#define VORONOI_CGINC

#include "../rand.cginc"

// Returns the distance to the nearest Voronoi cell center
fixed VoronoiNoise(in fixed2 _uv, in fixed _scale = 1.0, in fixed _speed = 0.0)
{
  const fixed TAU = 6.2831;

  _uv *= _scale;
  const int2 currentCell = floor(_uv);

  int2   neighborCell, neighborOffset;
  fixed  dist, minDist = 10.0;
  fixed2 randomCellPoint, neighborPoint;
  // Get the distance to the nearest point in the 3x3 tile neighborhood
  [unroll]
  for (int x=-1; x<=1; ++x){
    [unroll]
    for (int y=-1; y<=1; ++y)
    {
      neighborOffset = int2(x,y);
      neighborCell   = currentCell + neighborOffset;

      // Get a random point inside the current cell, based on the neighbor cell ID
      randomCellPoint = rand2(neighborCell);
      // Animate it
      randomCellPoint = 0.5 + 0.5 * sin(_speed*_Time.y + TAU*randomCellPoint);
      // Move it to the neighbor cell
      neighborPoint = randomCellPoint + neighborOffset;

      dist = length(neighborPoint - frac(_uv));

      //minDist = min(minDist, dist);
      if (dist < minDist) minDist = dist;
    }
  }
  return minDist;
}

// Returns the index of the closest cell
int2 VoronoiClosestCell(in fixed2 _uv, in fixed _scale = 1.0, in fixed _speed = 0.0)
{
  const fixed TAU = 6.2831;

  _uv *= _scale;
  const int2 currentCell = floor(_uv);

  int2   neighborCell, neighborOffset, closestCell;
  fixed  dist, minDist = 10.0;
  fixed2 randomCellPoint, neighborPoint;
  // Get the distance to the nearest point in the 3x3 tile neighborhood
  [unroll]
  for (int x=-1; x<=1; ++x){
    [unroll]
    for (int y=-1; y<=1; ++y)
    {
      neighborOffset = int2(x,y);
      neighborCell   = currentCell + neighborOffset;

      // Get a random point inside the current cell, based on the neighbor cell ID
      randomCellPoint = rand2(neighborCell);
      // Animate it
      randomCellPoint = 0.5 + 0.5 * sin(_speed*_Time.y + TAU*randomCellPoint);
      // Move it to the neighbor cell
      neighborPoint = randomCellPoint + neighborOffset;

      dist = length(neighborPoint - frac(_uv));

      if (dist < minDist)
      {
        minDist = dist;
        closestCell = neighborCell;
      }
    }
  }

  return closestCell;
}

// Returns the distance to the nearest Voronoi cell edge
fixed VoronoiEdges(in fixed2 _uv, in fixed _scale = 1.0, in fixed _speed = 0.0, in fixed _border = 0.0)
{
  const fixed TAU = 6.2831;

  fixed result = 10.0;

  _uv *= _scale;
  const int2 currentCell = floor(_uv);

  int2     closestCell, neighborCell, neighborOffset;
  fixed    dist, minDist = 10.0;
  fixed2   randomCellPoint, neighborPoint;
  fixed3x3 neighborhoodX, neighborhoodY;
  // First pass: Get the offset of the closest cell and store the neighborhood of points
  [unroll]
  for (int x=-1; x<=1; ++x){
    [unroll]
    for (int y=-1; y<=1; ++y)
    {
      neighborOffset = int2(x,y);
      neighborCell   = currentCell + neighborOffset;

      // Get a random point inside the current cell, based on the neighbor cell ID
      randomCellPoint = rand2(neighborCell);
      // Animate it
      randomCellPoint = 0.5 + 0.5 * sin(_speed*_Time.y + TAU*randomCellPoint);
      // Move it to the neighbor cell
      neighborPoint = randomCellPoint + neighborOffset;
      neighborhoodX[x+1][y+1] = neighborPoint.x;
      neighborhoodY[x+1][y+1] = neighborPoint.y;

      dist = length(neighborPoint - frac(_uv));

      if (dist < minDist)
      {
        minDist = dist;
        closestCell = int2(x+1,y+1);
      }
    }
  }

  // Second pass: Compute the distance to the nearest cell edge
  const fixed2 closestCellPoint = fixed2(neighborhoodX[closestCell.x][closestCell.y],
                                         neighborhoodY[closestCell.x][closestCell.y]);
  const fixed2 toClosestCell    = closestCellPoint - frac(_uv);

  fixed2 neighbor, midPoint, fromMidPoint, midToClosest;
  [unroll]
  for(int x=-1; x<=1; ++x)
    [unroll]
    for (int y=-1; y<=1; ++y) {
    {
      if (x == closestCell.x && y == closestCell.y) continue;

      neighbor = fixed2(neighborhoodX[x+1][y+1], neighborhoodY[x+1][y+1]);

      midPoint     = (closestCellPoint + neighbor) * 0.5;
      fromMidPoint = frac(_uv) - midPoint;
      midToClosest = normalize(closestCellPoint - midPoint);

      dist   = dot(fromMidPoint, midToClosest);
      result = min(result, dist);
    }
  }

  return result;
}

#endif
