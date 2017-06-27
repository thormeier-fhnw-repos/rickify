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

PImage currentHair;
PImage currentMouth;

int rectSize = 40;
int rectColorFill = color(200, 200, 200);
int rectColorFillHover = color(220, 220, 220);
int rectColorBorder = color(100, 100, 100);

boolean hoverRickButton = false;
boolean hoverMortyButton = false;

void setup() {
  size(640, 480);
  video = new Capture(this, 640/2, 480/2);
  opencvFrontalFace = new OpenCV(this, 640/2, 480/2);
  opencvFrontalFace.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  
  opencvMouth = new OpenCV(this, 640/2, 480/2);
  opencvMouth.loadCascade(OpenCV.CASCADE_MOUTH);

  rickHair = loadImage("rick_hair.png");
  rickDrool = loadImage("rick_drool.png");
  mortyHair = loadImage("morty_hair.png");
  mortyMouth = loadImage("morty_mouth.png");
  
  currentHair = mortyHair;
  currentMouth = mortyMouth;
  
  video.start();
}

void update(int x, int y) {
  if (x > 0 && y > 0 && x <= rectSize && y <= rectSize) {
    hoverRickButton = true;
    hoverMortyButton = false;
  } else if (x > rectSize && y > 0 && x <= rectSize * 2 && y <= rectSize) {
    hoverRickButton = false;
    hoverMortyButton = true;
  } else {
    hoverRickButton = hoverMortyButton = false;
  }
}

void mousePressed() {
  if (hoverRickButton) {
    currentHair = rickHair;
    currentMouth = rickDrool;
  }
  if (hoverMortyButton) {
    currentHair = mortyHair;
    currentMouth = mortyMouth;
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
  
  // Detect and draw drool on mouths
  Rectangle[] mouths = opencvMouth.detect();
  for (int i = 0; i < mouths.length; i++) {
    if (isMouth(faces, mouths[i])) {
      drawMouth(mouths[i].x, mouths[i].y, mouths[i].width, mouths[i].height, currentMouth);
    }
  }

  update(mouseX / 2, mouseY / 2);

  drawRickButton();
  drawMortyButton();
}

void drawRickButton() {
  drawButton(0, 0, rickHair, hoverRickButton);
}

void drawMortyButton() {
  drawButton(rectSize, 0, mortyHair, hoverMortyButton);
}

void drawButton(int x, int y, PImage image, boolean hovering) {
  // Button outlines
  if (hovering) {
    fill(rectColorFillHover);
  } else {
    fill(rectColorFill);
  }
  stroke(rectColorBorder);
  strokeWeight(2);
  rect(x, y, rectSize, rectSize);
  
  // Fit width and height to be in the button
  int factor = image.height > image.width ? image.height / rectSize : image.width / rectSize;
  int fitWidth = image.width / factor;
  int fitHeight = image.height / factor;
  
  int fitX = x + (rectSize - fitWidth) / 2;
  int fitY = y + (rectSize - fitHeight) / 2;
  
  // Display image on button
  image(image, fitX, fitY, fitWidth, fitHeight);
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

    int faceBottomLeftY = faceTopLeftY + (height / 3);

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
  
  float heightOffset = height / 8;
  
  float widthDiff = width - faceWidth;
  float heightDiff = height - faceHeight;
  
  float drawX = x - (widthDiff / 2);
  float drawY = y - (heightDiff / 2) - heightOffset;

  image(hair, drawX, drawY, width, height);
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

void captureEvent(Capture c) {
  c.read();
}