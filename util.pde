boolean overRect(int x, int y, int width, int height) 
{
  if (mouseX >= x && mouseX <= x+width && 
    mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

void doPhysics()
{   // Iterative relaxation via weighted Lloyd's algorithm.

  int temp;
  int CountTemp;

  if (VoronoiCalculated == false)
  {  // Part I: Calculate voronoi cell diagram of the points.

    StatusDisplay = "Calculating Voronoi diagram "; 

    //    float millisBaseline = millis();  // Baseline for timing studies
    //    println("Baseline.  Time = " + (millis() - millisBaseline) );


    if (vorPointsAdded == 0)
      voronoi = new Voronoi();  // Erase mesh

    temp = vorPointsAdded + 500;   // This line: VoronoiPointsPerPass  (Feel free to edit this number.)
    if (temp > maxParticles) 
      temp = maxParticles; 

    //    for (int i = vorPointsAdded; i < temp; ++i) {  
    for (int i = vorPointsAdded; i < temp; i++) {  


      // Optional, for diagnostics:::
      //  println("particles[i].x, particles[i].y " + particles[i].x + ", " + particles[i].y );

      voronoi.addPoint(new Vec2D(particles[i].x, particles[i].y ));
      vorPointsAdded++;
    }   

    if (vorPointsAdded >= maxParticles)
    {

      //    println("Points added.  Time = " + (millis() - millisBaseline) );

      cellsTotal =  (voronoi.getRegions().size());
      vorPointsAdded = 0;
      cellsCalculated = 0;
      cellsCalculatedLast = 0;

      RegionList = new Polygon2D[cellsTotal];

      int i = 0;
      for (Polygon2D poly : voronoi.getRegions()) {
        RegionList[i++] = poly;  // Build array of polygons
      }
      VoronoiCalculated = true;
    }
  } else
  {    // Part II: Calculate weighted centroids of cells.
    //  float millisBaseline = millis();
    //  println("fps = " + frameRate );

    StatusDisplay = "Calculating weighted centroids"; 

    temp = cellsCalculated + 500;   // This line: CentroidsPerPass  (Feel free to edit this number.)
    // Higher values give slightly faster computation, but a less responsive GUI.
    // Default value: 500

    // Time/frame @ 100: 2.07 @ 50 frames in
    // Time/frame @ 200: 1.575 @ 50
    // Time/frame @ 500: 1.44 @ 50

    if (temp > cellsTotal)
    {
      temp = cellsTotal;
    }

    for (int i=cellsCalculated; i< temp; i++) {  

      float xMax = 0;
      float xMin = mainwidth;
      float yMax = 0;
      float yMin = mainheight;
      float xt, yt;

      Polygon2D region = clip.clipPolygon(RegionList[i]);


      for (Vec2D v : region.vertices) { 

        xt = v.x;
        yt = v.y;

        if (xt < xMin)
          xMin = xt;
        if (xt > xMax)
          xMax = xt;
        if (yt < yMin)
          yMin = yt;
        if (yt > yMax)
          yMax = yt;
      }


      float xDiff = xMax - xMin;
      float yDiff = yMax - yMin;
      float maxSize = max(xDiff, yDiff);
      float minSize = min(xDiff, yDiff);

      float scaleFactor = 1.0;

      // Maximum voronoi cell extent should be between
      // cellBuffer/2 and cellBuffer in size.

      while (maxSize > cellBuffer)
      {
        scaleFactor *= 0.5;
        maxSize *= 0.5;
      }

      while (maxSize < (cellBuffer/2))
      {
        scaleFactor *= 2;
        maxSize *= 2;
      }  

      if ((minSize * scaleFactor) > (cellBuffer/2))
      {   // Special correction for objects of near-unity (square-like) aspect ratio, 
        // which have larger area *and* where it is less essential to find the exact centroid:
        scaleFactor *= 0.5;
      }

      float StepSize = (1/scaleFactor);

      float xSum = 0;
      float ySum = 0;
      float dSum = 0;       
      float PicDensity = 1.0; 


      if (invertImg)
        for (float x=xMin; x<=xMax; x += StepSize) {
          for (float y=yMin; y<=yMax; y += StepSize) {

            Vec2D p0 = new Vec2D(x, y);
            if (region.containsPoint(p0)) { 

              // Thanks to polygon clipping, NO vertices will be beyond the sides of imgblur.  
              PicDensity = 0.001 + (brightness(imgblur.pixels[ round(y)*imgblur.width + round(x) ]));  

              xSum += PicDensity * x;
              ySum += PicDensity * y; 
              dSum += PicDensity;
            }
          }
        } else
        for (float x=xMin; x<=xMax; x += StepSize) {
          for (float y=yMin; y<=yMax; y += StepSize) {

            Vec2D p0 = new Vec2D(x, y);
            if (region.containsPoint(p0)) {

              // Thanks to polygon clipping, NO vertices will be beyond the sides of imgblur. 
              PicDensity = 255.001 - (brightness(imgblur.pixels[ round(y)*imgblur.width + round(x) ]));  


              xSum += PicDensity * x;
              ySum += PicDensity * y; 
              dSum += PicDensity;
            }
          }
        }  

      if (dSum > 0)
      {
        xSum /= dSum;
        ySum /= dSum;
      }

      Vec2D centr;


      float xTemp  = (xSum);
      float yTemp  = (ySum);


      if ((xTemp <= lowBorderX) || (xTemp >= hiBorderX) || (yTemp <= lowBorderY) || (yTemp >= hiBorderY)) {
        // If new centroid is computed to be outside the visible region, use the geometric centroid instead.
        // This will help to prevent runaway points due to numerical artifacts. 
        centr = region.getCentroid(); 
        xTemp = centr.x;
        yTemp = centr.y;

        // Enforce sides, if absolutely necessary:  (Failure to do so *will* cause a crash, eventually.)

        if (xTemp <= lowBorderX)
          xTemp = lowBorderX + 1; 
        if (xTemp >= hiBorderX)
          xTemp = hiBorderX - 1; 
        if (yTemp <= lowBorderY)
          yTemp = lowBorderY + 1; 
        if (yTemp >= hiBorderY)
          yTemp = hiBorderY - 1;
      }      

      particles[i].x = xTemp;
      particles[i].y = yTemp;

      cellsCalculated++;
    } 


    //  println("cellsCalculated = " + cellsCalculated );
    //  println("cellsTotal = " + cellsTotal );

    if (cellsCalculated >= cellsTotal)
    {
      VoronoiCalculated = false; 
      Generation++;
      println("Generation = " + Generation );

      frameTime = (millis() - millisLastFrame)/1000;
      millisLastFrame = millis();
    }
  }
}


void OptimizePlotPath()
{ 
  int temp;
  // Calculate and show "optimized" plotting path, beneath points.

  StatusDisplay = "Optimizing plotting path";
  /*
  if (RouteStep % 100 == 0) {
   println("RouteStep:" + RouteStep);
   println("fps = " + frameRate );
   }
   */

  Vec2D p1;


  if (RouteStep == 0)
  {

    float cutoffScaled = 1 - cutoff;
    // Begin process of optimizing plotting route, by flagging particles that will be shown.

    particleRouteLength = 0;

    boolean particleRouteTemp[] = new boolean[maxParticles]; 

    for (int i = 0; i < maxParticles; ++i) {

      particleRouteTemp[i] = false;

      int px = (int) particles[i].x;
      int py = (int) particles[i].y;

      if ((px >= imgblur.width) || (py >= imgblur.height) || (px < 0) || (py < 0))
        continue;

      float v = (brightness(imgblur.pixels[ py*imgblur.width + px ]))/255; 

      if (invertImg)
        v = 1 - v;


      if (v < cutoffScaled) {
        particleRouteTemp[i] = true;   
        particleRouteLength++;
      }
    }

    particleRoute = new int[particleRouteLength]; 
    int tempCounter = 0;  
    for (int i = 0; i < maxParticles; ++i) { 

      if (particleRouteTemp[i])      
      {
        particleRoute[tempCounter] = i;
        tempCounter++;
      }
    }
    // These are the ONLY points to be drawn in the tour.
  }

  if (RouteStep < (particleRouteLength - 2)) 
  { 

    // Nearest neighbor ("Simple, Greedy") algorithm path optimization:

    int StopPoint = RouteStep + 1000;      // 1000 steps per frame displayed; you can edit this number!

    if (StopPoint > (particleRouteLength - 1))
      StopPoint = particleRouteLength - 1;

    for (int i = RouteStep; i < StopPoint; ++i) { 

      p1 = particles[particleRoute[RouteStep]];
      int ClosestParticle = 0; 
      float  distMin = Float.MAX_VALUE;

      for (int j = RouteStep + 1; j < (particleRouteLength - 1); ++j) { 
        Vec2D p2 = particles[particleRoute[j]];

        float  dx = p1.x - p2.x;
        float  dy = p1.y - p2.y;
        float  distance = (float) (dx*dx+dy*dy);  // Only looking for closest; do not need sqrt factor!

        if (distance < distMin) {
          ClosestParticle = j; 
          distMin = distance;
        }
      }  

      temp = particleRoute[RouteStep + 1];
      //        p1 = particles[particleRoute[RouteStep + 1]];
      particleRoute[RouteStep + 1] = particleRoute[ClosestParticle];
      particleRoute[ClosestParticle] = temp;

      if (RouteStep < (particleRouteLength - 1))
        RouteStep++;
      else
      {
        println("Now optimizing plot path" );
      }
    }
  } else
  {     // Initial routing is complete
    // 2-opt heuristic optimization:
    // Identify a pair of edges that would become shorter by reversing part of the tour.

    for (int i = 0; i < 90000; ++i) {   // 1000 tests per frame; you can edit this number.

      int indexA = floor(random(particleRouteLength - 1));
      int indexB = floor(random(particleRouteLength - 1));

      if (Math.abs(indexA  - indexB) < 2)
        continue;

      if (indexB < indexA)
      {  // swap A, B.
        temp = indexB;
        indexB = indexA;
        indexA = temp;
      }

      Vec2D a0 = particles[particleRoute[indexA]];
      Vec2D a1 = particles[particleRoute[indexA + 1]];
      Vec2D b0 = particles[particleRoute[indexB]];
      Vec2D b1 = particles[particleRoute[indexB + 1]];

      // Original distance:
      float  dx = a0.x - a1.x;
      float  dy = a0.y - a1.y;
      float  distance = (float) (dx*dx+dy*dy);  // Only a comparison; do not need sqrt factor! 
      dx = b0.x - b1.x;
      dy = b0.y - b1.y;
      distance += (float) (dx*dx+dy*dy);  //  Only a comparison; do not need sqrt factor! 

      // Possible shorter distance?
      dx = a0.x - b0.x;
      dy = a0.y - b0.y;
      float distance2 = (float) (dx*dx+dy*dy);  //  Only a comparison; do not need sqrt factor! 
      dx = a1.x - b1.x;
      dy = a1.y - b1.y;
      distance2 += (float) (dx*dx+dy*dy);  // Only a comparison; do not need sqrt factor! 

      if (distance2 < distance)
      {
        // Reverse tour between a1 and b0.   

        int indexhigh = indexB;
        int indexlow = indexA + 1;

        //      println("Shorten!" + frameRate );

        while (indexhigh > indexlow)
        {

          temp = particleRoute[indexlow];
          particleRoute[indexlow] = particleRoute[indexhigh];
          particleRoute[indexhigh] = temp;

          indexhigh--;
          indexlow++;
        }
      }
    }
  }

  frameTime = (millis() - millisLastFrame)/1000;
  millisLastFrame = millis();
}