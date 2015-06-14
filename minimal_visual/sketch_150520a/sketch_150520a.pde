import processing.video.*;

import codeanticode.syphon.*;

SyphonServer server;

import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
  
Minim minim;
BeatDetect beat;
BeatListener bl;
AudioInput input;
AudioOutput out;
FFT fft;

float h, w;

float theta = 0;
int sz = 500;

float easing =  0.5;
float dim = 0;
float unitone=0;

Blob[] blobs;
int circles = 150;
int nblobs = 20;

float white = 0.95;

void setup() {
  // GENERIC -------------------------------------------
  
  beat = new BeatDetect();
  
  size (sz, sz, OPENGL);
  frameRate(60);
  colorMode(HSB, 1);
  strokeWeight(1.9);
  noFill();
  smooth();
  h = height /2; w = width /2;
  
  minim = new Minim (this);
  input = minim.getLineIn (Minim.STEREO, 1024*4);
  fft = new FFT (input.bufferSize (), 
                 input.sampleRate ());
  beat = new BeatDetect(input.bufferSize(), input.sampleRate());
  beat.setSensitivity(300);  
  bl = new BeatListener(beat, input);  

  // SYPHON
  server = new SyphonServer(this, "Spirals");
  
  
  // ANIMATION OBJECTS -------------------------------------
  
  // Initialize dynamic objects
  blobs = new Blob[100000];
  for (int c = 0; c<circles; c++){
    for (int b = 0; b<nblobs; b++){
      float cuni = map(c, 0, circles, 0, 1);
      float cunipi = cuni * TWO_PI;
      
      float buni = map(c, 0, nblobs, 0, 1);
      float bunipi = buni * TWO_PI;
      
      float r = (buni-0.5)*2;
      
      float angle = map(b,0,nblobs,0,TWO_PI);
      float zpos = map(c, 0, circles, 50, 380);
      

      float cangle = angle;
      float cradius = 100 + 50 * sin(cunipi) ; //*cuni+10;
      
      float cx = h  ; //+ 50 * sin(cuni * TWO_PI);
      float cy = w ; //+ 50 * cos(cuni * TWO_PI);;
      float cz = 200 + 100 * sin(cunipi * 2);
      
      blobs[c*circles+b] = new Blob(cx,cy,cz, cangle, cradius);
      
      println("---- c:" + c + " b:" + b);
      println("zpos "+zpos);
      println("angle "+angle/TWO_PI);
    }
  }
}


void draw () {
  // GENERIC -------------------------------------------
  
  theta+=0.01;
  beat.detect(input.mix);

  dim = ease(dim, input.mix.level () * 100, 0.8);
  
  background(0.3,0.1);
  //if (dim > 2 && beat.isOnset()) paper(35);
  //paper(35); 
  noFill();
  unitone = ease(unitone, map(findNote(), 0, 100, 0, 1), 0.6); // maximum frequency band
  lights();

  // LIGHTING ------------------------------------------
  //pointLight(51, 102, 255, 65, 60, 100);
  //pointLight(200, 40, 60, -65, -60, -150);

  //ambientLight(70, 70, 10);



  // CAMERA -------------------------------------------
  
  float fov = PI/3.0+float(mouseX)/100;
  float cameraZ = (height/2.0) / tan(fov/2.0);

  //perspective(fov, float(width)/float(height), 
  //cameraZ/10.0, cameraZ*10.0);
  
  float eyeX = mouseX*1.5;
  float eyeY = mouseY*1.5;
  
  float zcam = 0;
  if (mousePressed){
     zcam = mouseY;
  }
  
  camera(eyeX, eyeY, (height/2.0) / tan(PI*30.0 / 180.0),
  mouseX, mouseY, zcam, 
  0, 1, 0); 

  // ANIMATION ----------------------------------------
  for (int c = 0; c<circles; c++){
    for (int i = 0; i<nblobs; i++){
      blobs[c*circles+i].draw();
    }
  }



  // TECH OUTPUT  --------------------------------------
  fill(1);
  noStroke();
  text("dim: "+ round(dim*100.0)/100.0, 4, 15);
  text("beat: ", 4, 30);
  if (beat.isKick()) ellipse(40, 26, 8, 8);
  text("fps: " + round(frameRate*10.0)/10.0, 4, 45); 

  //server.sendScreen();
}


void stop()
{
  input.close();
  minim.stop();
  super.stop();
}







