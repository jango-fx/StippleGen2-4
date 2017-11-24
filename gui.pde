void initGUI()
{
  textFont(createFont("SansSerif", 10));

  cp5 = new ControlP5(this);

  int leftcolumwidth = 225;

  int GUItop = mainheight + 15;
  int GUI2ndRow = 4;   // Spacing for firt row after group heading
  int GuiRowSpacing = 14;  // Spacing for subsequent rows
  int GUIFudge = mainheight + 19;  // I wish that we didn't need ONE MORE of these stupid spacings.


  ControlGroup l3 = cp5.addGroup("Primary controls (Changing will restart)", 10, GUItop, 225);

  cp5.addSlider("Stipples", 10, 10000, maxParticles, 10, GUI2ndRow, 150, 10).setGroup(l3);    

  InvertOnOff = cp5.addButton("INVERT_IMG", 10, 10, GUI2ndRow + GuiRowSpacing, 190, 10).setGroup(l3); 
  InvertOnOff.setCaptionLabel("Black stipples, White Background");


  Button LoadButton = cp5.addButton("LOAD_FILE", 10, 10, GUIFudge + 3*GuiRowSpacing, 175, 10);
  LoadButton.setCaptionLabel("LOAD IMAGE FILE (.PNG, .JPG, or .GIF)");

  cp5.addButton("QUIT", 10, 205, GUIFudge + 3*GuiRowSpacing, 30, 10);

  cp5.addButton("SAVE_STIPPLES", 10, 25, GUIFudge + 4*GuiRowSpacing, 160, 10);
  cp5.getController("SAVE_STIPPLES").setCaptionLabel("Save Stipple File (.SVG format)");

  cp5.addButton("SAVE_PATH", 10, 25, GUIFudge + 5*GuiRowSpacing, 160, 10); 
  cp5.getController("SAVE_PATH").setCaptionLabel("Save \"TSP\" Path (.SVG format)");


  ControlGroup l5 = cp5.addGroup("Display Options - Updated on next generation", leftcolumwidth+50, GUItop, 225);

  cp5.addSlider("Min_Dot_Size", .5, 8, 2, 10, 4, 140, 10).setGroup(l5); 
  cp5.getController("Min_Dot_Size").setValue(MinDotSize);
  cp5.getController("Min_Dot_Size").setCaptionLabel("Min. Dot Size");

  cp5.addSlider("Dot_Size_Range", 0, 20, 5, 10, 18, 140, 10).setGroup(l5);  
  cp5.getController("Dot_Size_Range").setValue(DotSizeFactor); 
  cp5.getController("Dot_Size_Range").setCaptionLabel("Dot Size Range");

  cp5.addSlider("White_Cutoff", 0, 1, 0, 10, 32, 140, 10).setGroup(l5); 
  cp5.getController("White_Cutoff").setValue(cutoff);
  cp5.getController("White_Cutoff").setCaptionLabel("White Cutoff");


  ImgOnOff = cp5.addButton("IMG_ON_OFF", 10, 10, 46, 90, 10);
  ImgOnOff.setGroup(l5);
  ImgOnOff.setCaptionLabel("Image BG >> Hide");

  CellOnOff = cp5.addButton("CELLS_ON_OFF", 10, 110, 46, 90, 10);
  CellOnOff.setGroup(l5);
  CellOnOff.setCaptionLabel("Cells >> Hide");

  PauseButton = cp5.addButton("Pause", 10, 10, 60, 190, 10);
  PauseButton.setGroup(l5);
  PauseButton.setCaptionLabel("Pause (to calculate TSP path)");

  OrderOnOff = cp5.addButton("ORDER_ON_OFF", 10, 10, 74, 190, 10);
  OrderOnOff.setGroup(l5);
  OrderOnOff.setCaptionLabel("Plotting path >> shown while paused");

  TextColumnStart =  2 * leftcolumwidth + 100;
}



void LOAD_FILE(float theValue) {  
  println(":::LOAD JPG, GIF or PNG FILE:::");

  selectInput("Select a file to process:", "fileSelected");  // Opens file chooser
} //End Load File

void SAVE_PATH(float theValue) {  
  FileModeTSP = true;
  SAVE_SVG(0);
}

void SAVE_STIPPLES(float theValue) {  
  FileModeTSP = false;
  SAVE_SVG(0);
}

void SAVE_SVG(float theValue) {  

  if (pausemode != true) {
    Pause(0.0);
    ErrorDisplay = "Error: PAUSE before saving.";
    ErrorTime = millis();
    ErrorDisp = true;
  } else {

    selectOutput("Output .svg file name:", "SavefileSelected");
  }
}




void QUIT(float theValue) { 
  exit();
}


void ORDER_ON_OFF(float theValue) {  
  if (showPath) {
    showPath  = false;
    OrderOnOff.setCaptionLabel("Plotting path >> Hide");
  } else {
    showPath  = true;
    OrderOnOff.setCaptionLabel("Plotting path >> Shown while paused");
  }
} 

void CELLS_ON_OFF(float theValue) {  
  if (showCells) {
    showCells  = false;
    CellOnOff.setCaptionLabel("Cells >> Hide");
  } else {
    showCells  = true;
    CellOnOff.setCaptionLabel("Cells >> Show");
  }
}  



void IMG_ON_OFF(float theValue) {  
  if (showBG) {
    showBG  = false;
    ImgOnOff.setCaptionLabel("Image BG >> Hide");
  } else {
    showBG  = true;
    ImgOnOff.setCaptionLabel("Image BG >> Show");
  }
} 


void INVERT_IMG(float theValue) {  
  if (invertImg) {
    invertImg  = false;
    InvertOnOff.setCaptionLabel("Black stipples, White Background");
    cp5.getController("White_Cutoff").setCaptionLabel("White Cutoff");
  } else {
    invertImg  = true;
    InvertOnOff.setCaptionLabel("White stipples, Black Background");
    cp5.getController("White_Cutoff").setCaptionLabel("Black Cutoff");
  }

  ReInitiallizeArray = true;
  pausemode =  false;
} 




void Pause(float theValue) { 
  // Main particle array setup (to be repeated if necessary):

  if  (pausemode)
  {
    pausemode = false;
    println("Resuming.");
    PauseButton.setCaptionLabel("Pause (to calculate TSP path)");
  } else
  {
    pausemode = true;
    println("Paused. Press PAUSE again to resume.");
    PauseButton.setCaptionLabel("Paused (calculating TSP path)");
  }
  RouteStep = 0;
} 


void Stipples(int inValue) { 

  if (maxParticles != (int) inValue) {
    println("Update:  Stipple Count -> " + inValue); 
    ReInitiallizeArray = true;
    pausemode =  false;
  }
}





void Min_Dot_Size(float inValue) {
  if (MinDotSize != inValue) {
    println("Update: Min_Dot_Size -> "+inValue);  
    MinDotSize = inValue; 
    MaxDotSize = MinDotSize* (1 + DotSizeFactor);
  }
} 


void Dot_Size_Range(float inValue) {  
  if (DotSizeFactor != inValue) {
    println("Update: Dot Size Range -> "+inValue); 
    DotSizeFactor = inValue;
    MaxDotSize = MinDotSize* (1 + DotSizeFactor);
  }
} 


void White_Cutoff(float inValue) {
  if (cutoff != inValue) {
    println("Update: White_Cutoff -> "+inValue); 
    cutoff = inValue; 
    RouteStep = 0; // Reset TSP path
  }
} 


void  DoBackgrounds() {
  if (showBG)
    image(img, 0, 0);    // Show original (cropped and scaled, but not blurred!) image in background
  else { 

    if (invertImg)
      fill(0);
    else
      fill(255);

    rect(0, 0, mainwidth, mainheight);
  }
}