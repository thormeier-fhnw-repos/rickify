import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencvFrontalFace;
OpenCV opencvMouth;
PImage rickHair;
PImage rickDrool;
PImage mortyHair;
PImage mortyMouth;
PImage showMeWhatYouGot;
PImage[] drools = new PImage[10];
PImage meeseeks;

PImage currentHair;
PImage currentMouth;

int rectSize = 30;
int rectBorderSize = 2;
int rectColorFill = color(200, 200, 200);
int rectColorFillHover = color(220, 220, 220);
int rectColorBorder = color(100, 100, 100);

boolean hoverRickButton = false;
boolean hoverMortyButton = false;
boolean hoverShowmewhatyougotButton = false;
boolean hoverMeeseeksButton = false;
boolean hoverScreenCapButton = false;
boolean hasMouthAnimation = false;

int savedMessageStartTimeMillis = 0;
int savedMessageDuration = 2500;

int width = 640;
int height = 480;
int droolCount = 0;

void setup() {
  size(640, 480);
  video = new Capture(this, width/2, height/2);
  opencvFrontalFace = new OpenCV(this, width/2, height/2);
  opencvFrontalFace.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  
  opencvMouth = new OpenCV(this, 640/2, 480/2);
  opencvMouth.loadCascade(OpenCV.CASCADE_MOUTH);
  
  mortyHair = loadImage("images/morty_hair.png");
  mortyMouth = loadImage("images/morty_mouth.png");
  rickHair = loadImage("images/rick_hair.png");
  rickDrool = loadImage("images/rick_drool.png");
  showMeWhatYouGot = loadImage("images/show_me_what_you_got.png");
  meeseeks = loadImage("images/meeseeks.png");
  
  currentHair = rickHair;
  currentMouth = rickDrool;
  hasMouthAnimation = true;
  
  getDroolsImgs();
  
  video.start();
}

void update(int x, int y) {
  if (x > 0 && y > 0 && x <= rectSize && y <= rectSize) {
    hoverRickButton = true;
    hoverMortyButton = false;
    hoverShowmewhatyougotButton = false;
    hoverMeeseeksButton = false;
    hoverScreenCapButton = false;
  } else if (x > rectSize && y > 0 && x <= rectSize * 2 && y <= rectSize) {
    hoverRickButton = false;
    hoverMortyButton = true;
    hoverShowmewhatyougotButton = false;
    hoverMeeseeksButton = false;
    hoverScreenCapButton = false;
  } else if (x > rectSize * 2 && y > 0 && x <= rectSize * 3 && y <= rectSize) {
    hoverRickButton = false;
    hoverMortyButton = false;
    hoverShowmewhatyougotButton = true;
    hoverMeeseeksButton = false;
    hoverScreenCapButton = false;
  } else if (x > rectSize * 3 && y > 0 && x <= rectSize * 4 && y <= rectSize) {
    hoverRickButton = false;
    hoverMortyButton = false;
    hoverShowmewhatyougotButton = false;
    hoverMeeseeksButton = true;
    hoverScreenCapButton = false;    
  } else if (x > rectSize * 4 && y > 0 && x <= rectSize * 5 && y <= rectSize) {
    hoverRickButton = false;
    hoverMortyButton = false;
    hoverShowmewhatyougotButton = false;
    hoverMeeseeksButton = false;
    hoverScreenCapButton = true;    
  } else {
    hoverRickButton = hoverMortyButton = hoverScreenCapButton = hoverShowmewhatyougotButton = hoverMeeseeksButton = false;
  }
}

void mousePressed() {
  if (hoverRickButton) {
    currentHair = rickHair;
    currentMouth = rickDrool;
    hasMouthAnimation = true;
  }
  if (hoverMortyButton) {
    currentHair = mortyHair;
    currentMouth = mortyMouth;
    hasMouthAnimation = false;
  }
  if (hoverShowmewhatyougotButton) {
    currentHair = showMeWhatYouGot;
    currentMouth = null;
    hasMouthAnimation = false;
  }
  if (hoverMeeseeksButton) {
    currentHair = meeseeks;
    currentMouth = null;
    hasMouthAnimation = false;
  }
  if (hoverScreenCapButton) {
    String filename = year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second();
    save("screencaps/" + filename + ".jpg");
    savedMessageStartTimeMillis = millis();
    
  }
}

void draw() {  
  scale(2);
  opencvFrontalFace.loadImage(video);
  opencvMouth.loadImage(video);

  image(video, 0, 0);

  // Detect and draw faces
  Rectangle[] faces = opencvFrontalFace.detect();
  for (int i = 0; i < faces.length; i++) {
     drawHair(faces[i].x, faces[i].y, faces[i].width, faces[i].height, currentHair);
  }
  
  if (currentMouth != null) {
    // Detect and draw drool on mouths
    Rectangle[] mouths = opencvMouth.detect();
    for (int i = 0; i < mouths.length; i++) {
      if (isMouth(faces, mouths[i])) {
        if (hasMouthAnimation) {
          currentMouth = drools[droolCount];
          droolCount++;
          if (droolCount >= drools.length) {
            droolCount = 0;
          }
        } 
        
        drawMouth(mouths[i].x, mouths[i].y, mouths[i].width, mouths[i].height, currentMouth);
      }
    }
  }

  update(mouseX / 2, mouseY / 2);

  // Buttons
  drawRickButton();
  drawMortyButton();
  drawShowmewhatyougotButton();
  drawMeeseeksButton();
  drawScreenCapButton();
  
  // "Saved" message
  if ((savedMessageStartTimeMillis + savedMessageDuration) > millis()) {
    strokeWeight(0);
    fill(color(200, 200, 200));
    rect(0, rectSize, 200, 20);
    
    fill(color(0, 0, 0));
    text("Saved photo to folder \"screencaps\"", 5, rectSize + 15); 
  }
}

void drawRickButton() {
  drawButton(0, 0, rickHair, hoverRickButton);
}

void drawMortyButton() {
  drawButton(rectSize, 0, mortyHair, hoverMortyButton);
}

void drawShowmewhatyougotButton() {
  drawButton(rectSize * 2, 0, showMeWhatYouGot, hoverShowmewhatyougotButton);
}

void drawMeeseeksButton() {
  drawButton(rectSize * 3, 0, meeseeks, hoverMeeseeksButton);
}

void drawScreenCapButton() {
  drawButton(rectSize * 4, 0, loadImage("images/camera-icon.png"), hoverScreenCapButton);
}

void drawButton(int x, int y, PImage image, boolean hovering) {
  // Button outlines
  if (hovering) {
    fill(rectColorFillHover);
  } else {
    fill(rectColorFill);
  }
  stroke(rectColorBorder);
  strokeWeight(rectBorderSize);
  rect(x, y, rectSize, rectSize);
  
  // Fit width and height to be in the button
  int factor = image.height > image.width ? image.height / rectSize : image.width / rectSize;
  int fitWidth = image.width / factor;
  int fitHeight = image.height / factor;
  
  int fitX = x + (rectSize - fitWidth) / 2;
  int fitY = y + (rectSize - fitHeight) / 2;
  
  // Display image on button
  image(image, fitX + rectBorderSize, fitY + rectBorderSize, fitWidth - (rectBorderSize * 2), fitHeight - (rectBorderSize * 2));
}

boolean isMouth(Rectangle[] faces, Rectangle mouth) {
  int mouthTopLeftX = mouth.x;
  int mouthTopLeftY = mouth.y;
  int mouthTopRightX = mouth.x + mouth.width;
  
  for (int i = 0; i < faces.length; i++) {
    int height = faces[i].height;
    int width = faces[i].width;
    
    int faceTopLeftX = faces[i].x;
    int faceTopLeftY = faces[i].y + ((height / 3) * 2); // Bottom third of the face
    
    int faceTopRightX = faceTopLeftX + width;

    float faceBottomLeftY = faceTopLeftY + (height / 5);

    if(
      (mouthTopLeftY > faceTopLeftY && mouthTopLeftY < faceBottomLeftY)
      && (mouthTopLeftX > faceTopLeftX && mouthTopLeftX < faceTopRightX)
      && (mouthTopRightX > faceTopLeftX && mouthTopRightX < faceTopRightX)
    ) {
      return true; 
    }
  }
  
  return false;
}

void drawHair(int x, int y, int faceWidth, int faceHeight, PImage hair) {
  float widthFactor = 1.5;
  float heightFactor = 1.5;
  
  float width = faceWidth * widthFactor;
  float height = faceHeight * heightFactor;

  float scaleFactor = hair.height / height;
  float widthScaled = hair.width / scaleFactor;
  
  float heightOffset = height / 8;
  float widthOffset = width / 20;
  
  float widthDiff = abs(width - widthScaled);
  float heightDiff = height - faceHeight;
  
  float drawX = x - (widthDiff / 2) - widthOffset;
  float drawY = y - (heightDiff / 2) - heightOffset;

  image(hair, drawX, drawY, widthScaled, height);
}

void drawMouth(int x, int y, int faceWidth, int faceHeight, PImage mouth) {
  float widthFactor = 1.8;
  float heightFactor = 1.8;
  
  float width = faceWidth * widthFactor;
  float height = faceHeight * heightFactor;
  
  float heightOffset = height / 8;
  
  float widthDiff = width - faceWidth;
  float heightDiff = height - faceHeight;
  
  float drawX = x - (widthDiff / 2);
  float drawY = y - (heightDiff / 2) - heightOffset;

  image(mouth, drawX, drawY, width, height);
}

void getDroolsImgs() {
  for (int i = 0; i < drools.length; i++) {
    drools[i] = loadImage("images/drool_animation/rick_drool_"+i+".png");
  }
}

void captureEvent(Capture c) {
  c.read();
}