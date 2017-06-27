import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencvFrontalFace;
OpenCV opencvMouth;
PImage rickHair;
PImage rickDrool;

void setup() {
  size(640, 480);
  video = new Capture(this, 640/2, 480/2);
  opencvFrontalFace = new OpenCV(this, 640/2, 480/2);
  opencvFrontalFace.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  
  opencvMouth = new OpenCV(this, 640/2, 480/2);
  opencvMouth.loadCascade(OpenCV.CASCADE_MOUTH);

  rickHair = loadImage("rick_hair.png");
  rickDrool = loadImage("rick_drool.png");

  video.start();
}

void draw() {
  scale(2);
  opencvFrontalFace.loadImage(video);
  opencvMouth.loadImage(video);

  image(video, 0, 0);
  
  // Detect and draw faces
  Rectangle[] faces = opencvFrontalFace.detect();
  for (int i = 0; i < faces.length; i++) {
     drawHair(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
  
  // Detect and draw drool on mouths
  Rectangle[] mouths = opencvMouth.detect();
  for (int i = 0; i < mouths.length; i++) {
    if (isMouth(faces, mouths[i])) {
      drawDrool(mouths[i].x, mouths[i].y, mouths[i].width, mouths[i].height);
    }
  }
}

boolean isMouth(Rectangle[] faces, Rectangle mouth) {
  int mouthTopX = mouth.x;
  int mouthTopY = mouth.x;
  int mouthBottomX = mouthTopX + mouth.width;
  int mouthBottomY = mouthTopY + mouth.height;
  
  for (int i = 0; i < faces.length; i++) {
    int faceTopX = faces[i].x;
    int faceTopY = faces[i].y + (faces[i].height / 3); // Bottom third of the face
    int faceBottomX = faceTopX + faces[i].width;
    int faceBottomY = faceTopY + faces[i].height;
    
    // If the mouth is in a face rectangle
    if (mouthTopX > faceTopX && mouthTopY > faceTopY && mouthBottomX < faceBottomX && mouthBottomY < faceBottomY) {
     return true; 
    }
  }
  
  return false;
}

void drawHair(int x, int y, int faceWidth, int faceHeight) {
  float widthFactor = 1.5;
  float heightFactor = 1.5;
  
  float width = faceWidth * widthFactor;
  float height = faceHeight * heightFactor;
  
  float heightOffset = height / 8;
  
  float widthDiff = width - faceWidth;
  float heightDiff = height - faceHeight;
  
  float drawX = x - (widthDiff / 2);
  float drawY = y - (heightDiff / 2) - heightOffset;

  image(rickHair, drawX, drawY, width, height);
}

void drawDrool(int x, int y, int faceWidth, int faceHeight) {
  float widthFactor = 1.5;
  float heightFactor = 1.5;
  
  float width = faceWidth * widthFactor;
  float height = faceHeight * heightFactor;
  
  float heightOffset = height / 8;
  
  float widthDiff = width - faceWidth;
  float heightDiff = height - faceHeight;
  
  float drawX = x - (widthDiff / 2);
  float drawY = y - (heightDiff / 2) - heightOffset;

  image(rickDrool, drawX, drawY, width, height);
}

void captureEvent(Capture c) {
  c.read();
}