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

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    //println("User selected " + selection.getAbsolutePath());

    String loadPath = selection.getAbsolutePath();

    // If a file was selected, print path to file 
    println("Loaded file: " + loadPath); 


    String[] p = splitTokens(loadPath, ".");
    boolean fileOK = false;

    if ( p[p.length - 1].equals("GIF"))
      fileOK = true;
    if ( p[p.length - 1].equals("gif"))
      fileOK = true;      
    if ( p[p.length - 1].equals("JPG"))
      fileOK = true;
    if ( p[p.length - 1].equals("jpg"))
      fileOK = true;   
    if ( p[p.length - 1].equals("TGA"))
      fileOK = true;
    if ( p[p.length - 1].equals("tga"))
      fileOK = true;   
    if ( p[p.length - 1].equals("PNG"))
      fileOK = true;
    if ( p[p.length - 1].equals("png"))
      fileOK = true;   

    println("File OK: " + fileOK); 

    if (fileOK) {
      imgload = loadImage(loadPath); 
      fileLoaded = true;
      // MainArraysetup();
      ReInitiallizeArray = true;
    } else {
      // Can't load file
      ErrorDisplay = "ERROR: BAD FILE TYPE";
      ErrorTime = millis();
      ErrorDisp = true;
    }
  }
}

void LoadImageAndScale() {

  int tempx = 0;
  int tempy = 0;

  img = createImage(mainwidth, mainheight, RGB);
  imgblur = createImage(mainwidth, mainheight, RGB);

  img.loadPixels();

  if (invertImg)
    for (int i = 0; i < img.pixels.length; i++) {
      img.pixels[i] = color(0);
    } else
    for (int i = 0; i < img.pixels.length; i++) {
      img.pixels[i] = color(255);
    }

  img.updatePixels();

  if ( fileLoaded == false) {
    // Load a demo image, at least until we have a "real" image to work with.

    imgload = loadImage("grace.jpg"); // Load demo image
    // Image source:  http://commons.wikimedia.org/wiki/File:Kelly,_Grace_(Rear_Window).jpg
  }

  if ((imgload.width > mainwidth) || (imgload.height > mainheight)) {

    if (((float) imgload.width / (float)imgload.height) > ((float) mainwidth / (float) mainheight))
    { 
      imgload.resize(mainwidth, 0);
    } else
    { 
      imgload.resize(0, mainheight);
    }
  } 

  if  (imgload.height < (mainheight - 2) ) { 
    tempy = (int) (( mainheight - imgload.height ) / 2) ;
  }
  if (imgload.width < (mainwidth - 2)) {
    tempx = (int) (( mainwidth - imgload.width ) / 2) ;
  }

  img.copy(imgload, 0, 0, imgload.width, imgload.height, tempx, tempy, imgload.width, imgload.height);
  // For background image!


  /* 
   // Optional gamma correction for background image.  
   img.loadPixels();
   
   float tempFloat;  
   float GammaValue = 1.0;  // Normally in the range 0.25 - 4.0
   
   for (int i = 0; i < img.pixels.length; i++) {
   tempFloat = brightness(img.pixels[i])/255;  
   img.pixels[i] = color(floor(255 * pow(tempFloat,GammaValue))); 
   } 
   img.updatePixels();
   */


  imgblur.copy(img, 0, 0, img.width, img.height, 0, 0, img.width, img.height);
  // This is a duplicate of the background image, that we will apply a blur to,
  // to reduce "high frequency" noise artifacts.

  imgblur.filter(BLUR, 1);  // Low-level blur filter to elminate pixel-to-pixel noise artifacts.
  imgblur.loadPixels();
}




void SavefileSelected(File selection) {
  if (selection == null) {
    // If a file was not selected
    println("No output file was selected...");
    ErrorDisplay = "ERROR: NO FILE NAME CHOSEN.";
    ErrorTime = millis();
    ErrorDisp = true;
  } else { 

    savePath = selection.getAbsolutePath();
    String[] p = splitTokens(savePath, ".");
    boolean fileOK = false;

    if ( p[p.length - 1].equals("SVG"))
      fileOK = true;
    if ( p[p.length - 1].equals("svg"))
      fileOK = true;      

    if (fileOK == false)
      savePath = savePath + ".svg";


    // If a file was selected, print path to folder 
    println("Save file: " + savePath);
    SaveNow = 1; 
    showPath  = true;

    ErrorDisplay = "SAVING FILE...";
    ErrorTime = millis();
    ErrorDisp = true;
  }
}