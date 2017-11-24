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


void dropEvent(DropEvent theDropEvent) {
  println("toString()\t"+theDropEvent.toString());

  if (theDropEvent.isFile() && theDropEvent.isImage())
  {
    fileSelected(theDropEvent.file());
  }
  // returns the DropTargetDropEvent, for further information see
  // http://java.sun.com/j2se/1.4.2/docs/api/java/awt/dnd/DropTargetDropEvent.html
  println("dropTargetDropEvent()\t"+theDropEvent.dropTargetDropEvent());
}