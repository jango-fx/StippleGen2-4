import controlP5.*;    

import toxi.geom.*;
import toxi.geom.mesh2d.*;
import toxi.util.datatypes.*;
import toxi.processing.*;
ToxiclibsSupport gfx;

import javax.swing.UIManager; 
import javax.swing.JFileChooser; 

import drop.*;


// Feel free to play with these three default settings:
int maxParticles = 2000;   // Max value is normally 10000.  Press 'x' key to allow 50000 stipples. (SLOW)
float MinDotSize = 1.75; //2;
float DotSizeFactor = 4;  //5;
float cutoff =  0;  // White cutoff value


int cellBuffer = 100;  //Scale each cell to fit in a cellBuffer-sized square window for computing the centroid.


// Display window and GUI area sizes:
int mainwidth; 
int mainheight;
int borderWidth;
int ctrlheight;
int TextColumnStart;



float lowBorderX;
float hiBorderX;
float lowBorderY;
float hiBorderY;



float MaxDotSize;
boolean ReInitiallizeArray; 
boolean pausemode;
boolean fileLoaded;
int SaveNow;
String savePath;
String[] FileOutput; 




String StatusDisplay = "Initializing, please wait. :)";
float millisLastFrame = 0;
float frameTime = 0;

String ErrorDisplay = "";
float ErrorTime;
Boolean ErrorDisp = false;


int Generation; 
int particleRouteLength;
int RouteStep; 

boolean showBG;
boolean showPath;
boolean showCells; 
boolean invertImg;
boolean TempShowCells;
boolean FileModeTSP;

int vorPointsAdded;
boolean VoronoiCalculated;

// Toxic libs library setup:
Voronoi voronoi; 
Polygon2D RegionList[];

PolygonClipper2D clip;  // polygon clipper

int cellsTotal, cellsCalculated, cellsCalculatedLast;


// ControlP5 GUI library variables setup
Textlabel  ProgName; 
Button  OrderOnOff, ImgOnOff, CellOnOff, InvertOnOff, PauseButton;
ControlP5 cp5; 

SDrop dragdrop;


PImage img, imgload, imgblur; 

Vec2D[] particles;
int[] particleRoute;


void MainArraysetup() { 
  // Main particle array initialization (to be called whenever necessary):

  LoadImageAndScale();

  // image(img, 0, 0); // SHOW BG IMG

  particles = new Vec2D[maxParticles];


  // Fill array by "rejection sampling"
  int  i = 0;
  while (i < maxParticles)
  {

    float fx = lowBorderX +  random(hiBorderX - lowBorderX);
    float fy = lowBorderY +  random(hiBorderY - lowBorderY);

    float p = brightness(imgblur.pixels[ floor(fy)*imgblur.width + floor(fx) ])/255; 
    // OK to use simple floor_ rounding here, because  this is a one-time operation,
    // creating the initial distribution that will be iterated.

    if (invertImg)
    {
      p =  1 - p;
    }

    if (random(1) >= p ) {  
      Vec2D p1 = new Vec2D(fx, fy);
      particles[i] = p1;  
      i++;
    }
  } 

  particleRouteLength = 0;
  Generation = 0; 
  millisLastFrame = millis();
  RouteStep = 0; 
  VoronoiCalculated = false;
  cellsCalculated = 0;
  vorPointsAdded = 0;
  voronoi = new Voronoi();  // Erase mesh
  TempShowCells = true;
  FileModeTSP = false;
} 

void settings()
{  
  borderWidth = 6;

  mainwidth = 800;
  mainheight = 600;
  ctrlheight = 110;

  size(mainwidth, mainheight + ctrlheight, JAVA2D);
}

void setup()
{
  gfx = new ToxiclibsSupport(this);

  lowBorderX =  borderWidth; //mainwidth*0.01; 
  hiBorderX = mainwidth - borderWidth; //mainwidth*0.98;
  lowBorderY = borderWidth; // mainheight*0.01;
  hiBorderY = mainheight - borderWidth;  //mainheight*0.98;

  int innerWidth = mainwidth - 2  * borderWidth;
  int innerHeight = mainheight - 2  * borderWidth;

  clip=new SutherlandHodgemanClipper(new Rect(lowBorderX, lowBorderY, innerWidth, innerHeight));

  MainArraysetup();   // Main particle array setup

  frameRate(24);

  smooth();
  noStroke();
  fill(153); // Background fill color, for control section

  initGUI();
  dragdrop = new SDrop(this);

  MaxDotSize = MinDotSize * (1 + DotSizeFactor);

  ReInitiallizeArray = false;
  pausemode = false;
  showBG  = false;
  invertImg  = false;
  showPath = true;
  showCells = false;
  fileLoaded = false;
  SaveNow = 0;
}


void draw()
{

  int i = 0;
  int temp;
  float dotScale = (MaxDotSize - MinDotSize);
  float cutoffScaled = 1 - cutoff;

  if (ReInitiallizeArray) {
    maxParticles = (int) cp5.getController("Stipples").getValue(); // Only change this here!

    MainArraysetup();
    ReInitiallizeArray = false;
  } 

  if (pausemode && (VoronoiCalculated == false))  
    OptimizePlotPath();
  else
    doPhysics();


  if (pausemode)
  {

    DoBackgrounds();

    // Draw paths:

    if ( showPath ) {

      stroke(128, 128, 255);   // Stroke color (blue)
      strokeWeight (1);

      for ( i = 0; i < (particleRouteLength - 1); ++i) {

        Vec2D p1 = particles[particleRoute[i]];
        Vec2D p2 = particles[particleRoute[i + 1]];

        line(p1.x, p1.y, p2.x, p2.y);
      }
    }


    if (invertImg)
      stroke(255);
    else
      stroke(0);

    for ( i = 0; i < particleRouteLength; ++i) {
      // Only show "routed" particles-- those above the white cutoff.

      Vec2D p1 = particles[particleRoute[i]];  
      int px = (int) p1.x;
      int py = (int) p1.y;

      float v = (brightness(imgblur.pixels[ py*imgblur.width + px ]))/255; 

      if (invertImg)
        v = 1 - v;

      strokeWeight (MaxDotSize -  v * dotScale);  
      point(px, py);
    }
  } else
  {      // NOT in pause mode.  i.e., just displaying stipples.
    if (cellsCalculated == 0) {

      DoBackgrounds();

      if (Generation == 0)
      {
        TempShowCells = true;
      }

      if (showCells || TempShowCells) {  // Draw voronoi cells, over background.
        strokeWeight(1);
        noFill();


        if (invertImg && (showBG == false))  // TODO -- if invertImg AND NOT background
          stroke(100);
        else
          stroke(200);

        //        stroke(200);

        i = 0;
        for (Polygon2D poly : voronoi.getRegions()) {
          //RegionList[i++] = poly; 
          gfx.polygon2D(clip.clipPolygon(poly));
        }
      }

      if (showCells) {
        // Show "before and after" centroids, when polygons are shown.

        strokeWeight (MinDotSize);  // Normal w/ Min & Max dot size
        for ( i = 0; i < maxParticles; ++i) {

          int px = (int) particles[i].x;
          int py = (int) particles[i].y;

          if ((px >= imgblur.width) || (py >= imgblur.height) || (px < 0) || (py < 0))
            continue;
          { 
            //Uncomment the following four lines, if you wish to display the "before" dots at weighted sizes.
            //float v = (brightness(imgblur.pixels[ py*imgblur.width + px ]))/255;  
            //if (invertImg)
            //v = 1 - v;
            //strokeWeight (MaxDotSize - v * dotScale);  
            point(px, py);
          }
        }
      }
    } else {
      // Stipple calculation is still underway

      if (TempShowCells)
      {
        DoBackgrounds(); 
        TempShowCells = false;
      }


      //      stroke(0);   // Stroke color


      if (invertImg)
        stroke(255);
      else
        stroke(0);

      for ( i = cellsCalculatedLast; i < cellsCalculated; ++i) {

        int px = (int) particles[i].x;
        int py = (int) particles[i].y;

        if ((px >= imgblur.width) || (py >= imgblur.height) || (px < 0) || (py < 0))
          continue;
        { 
          float v = (brightness(imgblur.pixels[ py*imgblur.width + px ]))/255; 

          if (invertImg)
            v = 1 - v;

          if (v < cutoffScaled) { 
            strokeWeight (MaxDotSize - v * dotScale);  
            point(px, py);
          }
        }
      }

      cellsCalculatedLast = cellsCalculated;
    }
  }

  noStroke();
  fill(100);   // Background fill color
  rect(0, mainheight, mainwidth, height); // Control area fill

  // Underlay for hyperlink:
  if (overRect(TextColumnStart - 10, mainheight + 35, 205, 20) )
  {
    fill(150); 
    rect(TextColumnStart - 10, mainheight + 35, 205, 20);
  }

  fill(255);   // Text color
  text("Generations completed: " + Generation, TextColumnStart, mainheight + 85); 
  text("Time/Frame: " + frameTime + " s", TextColumnStart, mainheight + 100);


  if (ErrorDisp)
  {
    fill(255, 0, 0);   // Text color
    text(ErrorDisplay, TextColumnStart, mainheight + 70);
    if ((millis() - ErrorTime) > 8000)
      ErrorDisp = false;
  } else
    text("Status: " + StatusDisplay, TextColumnStart, mainheight + 70);



  if (SaveNow > 0) {

    StatusDisplay = "Saving SVG File";
    SaveNow = 0;

    FileOutput = loadStrings("header.txt"); 

    String rowTemp;

    float SVGscale = (800.0 / (float) mainheight); 
    int xOffset = (int) (1600 - (SVGscale * mainwidth / 2));
    int yOffset = (int) (400 - (SVGscale * mainheight / 2));


    if (FileModeTSP) 
    { // Plot the PATH between the points only.

      println("Save TSP File (SVG)");

      // Path header::
      rowTemp = "<path style=\"fill:none;stroke:black;stroke-width:2px;stroke-linejoin:round;stroke-linecap:round;\" d=\"M "; 
      FileOutput = append(FileOutput, rowTemp);


      for ( i = 0; i < particleRouteLength; ++i) {

        Vec2D p1 = particles[particleRoute[i]];  

        float xTemp = SVGscale*p1.x + xOffset;
        float yTemp = SVGscale*p1.y + yOffset;        

        rowTemp = xTemp + " " + yTemp + "\r";

        FileOutput = append(FileOutput, rowTemp);
      } 
      FileOutput = append(FileOutput, "\" />"); // End path description
    } else {
      println("Save Stipple File (SVG)");

      for ( i = 0; i < particleRouteLength; ++i) {

        Vec2D p1 = particles[particleRoute[i]]; 

        int px = floor(p1.x);
        int py = floor(p1.y);

        float v = (brightness(imgblur.pixels[ py*imgblur.width + px ]))/255;  

        if (invertImg)
          v = 1 - v;

        float dotrad =  (MaxDotSize - v * dotScale)/2; 

        float xTemp = SVGscale*p1.x + xOffset;
        float yTemp = SVGscale*p1.y + yOffset; 

        rowTemp = "<circle cx=\"" + xTemp + "\" cy=\"" + yTemp + "\" r=\"" + dotrad +
          "\" style=\"fill:none;stroke:black;stroke-width:2;\"/>";

        // Typ:   <circle  cx="1600" cy="450" r="3" style="fill:none;stroke:black;stroke-width:2;"/>

        FileOutput = append(FileOutput, rowTemp);
      }
    }



    // SVG footer:
    FileOutput = append(FileOutput, "</g></g></svg>");
    saveStrings(savePath, FileOutput);
    FileModeTSP = false; // reset for next time

    if (FileModeTSP) 
      ErrorDisplay = "TSP Path .SVG file Saved";
    else
      ErrorDisplay = "Stipple .SVG file saved ";

    ErrorTime = millis();
    ErrorDisp = true;
  }
}