import codeanticode.syphon.*;

SyphonServer server;


int x, y;
int h, w;

float theta = 0;

int numLines = 3;
int maxLines = 10;
int numTriangles = 30;

float dim_multiplier = 1;
float dim_addition = 0;
float easing =  0.3;
float easing_c;
float dim = 0;
float dim_loud = 0.1;
float shift_multi;

int change_color_every_x_frames = 100;

color[] colorr;
color[] colorr_to;

PVector[] lineBase;
PVector[] lineTop;
PVector[] middle;
int xperLine;
int yperTriangle;

//float colorr = 1;

boolean runn = false;
boolean grown = false;


// Framebuffer

PGraphics buffer;
PGraphics background_buffer;

void setup() {
  size(500,500, P2D);
  h = height/2;
  w = width/2;
  frameRate(60);
  colorMode(HSB, 1);
  smooth();
  
  // buffer shit
  buffer = createGraphics(500, 500); 
  buffer.beginDraw();
  buffer.colorMode(HSB, 1);
  buffer.smooth();
  
  background_buffer = createGraphics(500, 500); 
  background_buffer.beginDraw();
  background_buffer.colorMode(HSB, 1);
  background_buffer.smooth();  
  
  minim = new Minim (this);
  input = minim.getLineIn (Minim.STEREO, 1024*4);
  fft = new FFT (input.bufferSize (), input.sampleRate ());
  beat = new BeatDetect();
  
  xperLine = width / numLines;
  yperTriangle = (int)(height*0.4)/numTriangles;
  lineBase = new PVector[numLines];
  lineTop = new PVector[numLines];
  middle = new PVector[numLines];
  
  colorr = new color[(numLines)*numTriangles];
  colorr_to = new color[(numLines)*numTriangles];
  
  for (int i = 1; i<numLines; i++) {
    // Stauchung, oben breiter, unten enger: shift (danach mit cos addieren/subtrahieren um ab der 
    // mitte des bildes das vorzeichen umzukehren)
    float shift = 0;
    shift = map(i,1,numLines,0,TWO_PI);
    lineBase[i] = new PVector(i * xperLine+random(-20,20) + cos(shift*TWO_PI) * 30, height);
    lineTop[i] = new PVector(i * xperLine+random(-20,20) - cos(shift*TWO_PI) * 50, 0);
  }
  for (int i = 1; i<numLines; i++) {
    middle[i] = new PVector();
  }
    set_colors();
  
  
  // SYPHON
  server = new SyphonServer(this, "Grotjahn");
    
}

void set_colors(){
  for (int i = 1; i<(numLines-1)*numTriangles; i++){
  colorr_to[i] = color(random(0,1),random(0,1),random(0,1));
  }
}

void change_colors(){
  // new colors every x frames
  easing_c = 0.1;
  if ( ( beat.isOnset() )) { 
    change_color_every_x_frames = (int)random(2,5);
    easing_c = 1;
    for (int i = 1; i<(numLines-1)*numTriangles; i++){
    colorr_to[i] = color(random(0,1),random(0,1),random(0,1));
  }
  }
  if (frameCount % change_color_every_x_frames == 0) {
    for (int i = 1; i<(numLines-1)*numTriangles; i++){
    colorr_to[i] = color(random(0,1),random(0,1),random(0,1));
  }
  }
  
  for (int i = 1; i<(numLines-1)*numTriangles; i++){
    colorr[i] = color(ease(hue(colorr[i]),hue(colorr_to[i]),easing_c), ease(saturation(colorr[i]),saturation(colorr_to[i]),easing_c), ease(brightness(colorr[i]),brightness(colorr_to[i]),easing_c) );
  }
}
void move_points() {
  for (int i = 1; i<numLines; i++) { 
    // get the vector along the lines to move the mid points along the lines
           PVector triangle_shift = new PVector(0,0);
           triangle_shift.set(middle[i].x, middle[i].y);
           PVector v1 = new PVector(lineTop[i].x,lineTop[i].y);
           triangle_shift.sub(v1);
           //triangle_shift.mult(j*0.05); 
           
  // SHIFT MULTIPLICATOR, HOW SHOULD THEY MOVE?
  shift_multi = ease(shift_multi, 0.1*sin(i+theta*TWO_PI*5)*map(dim,0,2,-10,100), easing);
  if (grown)
    shift_multi = ease(shift_multi, shift_multi * dim * 5, easing);
  // restrict the range of shift_multi
  if (shift_multi > 0.2) shift_multi = 0.2;
  if (shift_multi < -10) shift_multi = -10;

   // set the "middle" Vector, where the center of the triangles are, move this point to move all the triangles along the lines
   middle[i].set((lineTop[i].x+lineBase[i].x)/2+triangle_shift.x*shift_multi,(lineTop[i].y+lineBase[i].y)/2+triangle_shift.y*shift_multi);
  }
}

void draw_triangles() {
   for (int i = 1; i<numLines; i++) {
         for (int j = numTriangles; j>=1; j--) {
           
           buffer.stroke(0);
           buffer.strokeWeight(0.2);
           
           if (dim < dim_loud) buffer.noStroke();
           
           buffer.fill(colorr[i*numLines+j]);
           //fill(j*0.03,0.8,1); // beautiful colors

           // vector to middle of a line, then add/subtract a vector pointing to the end of the line
           // so we can stepwise translate along the line to make triangles at it
           PVector triangle_shift = new PVector(0,0);
           triangle_shift.set(middle[i].x, middle[i].y);
           PVector v1 = new PVector(lineTop[i].x,lineTop[i].y);
           triangle_shift.sub(v1);
           triangle_shift.mult(j*0.04); 

           // beat enlarger
             if (beat.isOnset())
                triangle_shift.mult(4);
           
           // slowly enlarge triangles:
          if (theta > 0.65)
           triangle_shift.mult(0.65);

           if((i-1)%2==0) { // for every second line
             // triangles to both diractions of a line, first:
              if (i < numLines - 1)
             buffer.triangle(middle[i].x+triangle_shift.x,middle[i].y+triangle_shift.y, middle[i].x-triangle_shift.x,middle[i].y-triangle_shift.y, middle[i+1].x,middle[i+1].y);
             if (i > 2 && i < numLines){ // this is the other direction
             if (dim > dim_loud) buffer.fill(colorr[i*numLines-1+j]);
             buffer.triangle(middle[i].x+triangle_shift.x,middle[i].y+triangle_shift.y, middle[i].x-triangle_shift.x,middle[i].y-triangle_shift.y, middle[i-1].x,middle[i-1].y);
             }
           }

           // ++++++++++++ DEBUG OUTPUT
           /*strokeWeight(5);
           //point(200,200+theta*100);
           //println("middle: " + middle[i].x + " " + middle[i].y);
           stroke(0.8);
           point(middle[i].x,middle[i].y);
           stroke(0);
           point( middle[i].x+ triangle_shift.x, middle[i].y+triangle_shift.y);
           point( middle[i].x- triangle_shift.x, middle[i].y - triangle_shift.y);
           //println("then: " + triangle_shift.x + " " + triangle_shift.y);
           */
         }
   }
}

void init_lines() {
  xperLine = width / numLines;
  yperTriangle = (int)(height*0.4)/numTriangles;
  lineBase = new PVector[numLines];
  lineTop = new PVector[numLines];
  middle = new PVector[numLines];
  
  colorr = new color[(numLines-1)*numTriangles];
  colorr_to = new color[(numLines-1)*numTriangles];
  
  for (int i = 1; i<numLines; i++) {
    // Stauchung, oben breiter, unten enger: shift (danach mit cos addieren/subtrahieren um ab der 
    // mitte des bildes das vorzeichen umzukehren)
    float shift = 0;
    shift = map(i,1,numLines,0,TWO_PI);
    lineBase[i] = new PVector(i * xperLine+random(-20,20) + cos(shift*TWO_PI) * 30, height);
    lineTop[i] = new PVector(i * xperLine+random(-20,20) - cos(shift*TWO_PI) * 50, 0);
  }
  for (int i = 1; i<numLines; i++) {
    middle[i] = new PVector();
  }
    set_colors();
}
   

void draw() {
  buffer.fill(0.8,0,8,.9);
  // add one line after the other at the beginning, until it is "grown"
  if (beat.isOnset() && (numLines < maxLines) && random(1)< 0.3) {
    numLines++;
    init_lines();
    if (numLines == maxLines) grown = true;
  }
  // if it is grown, then change randomly the number of lines etc.
  if (grown && random(0,1)< 0.003)  {numLines = ((int)random(3,maxLines/2))*2 ; init_lines();}
  // blur a little bit
  if (grown &&  dim > dim_loud) { buffer.fill(0.8,0,8,.2); }
   
  buffer.noStroke();
  buffer.rect(0, 0, width, height);
  //background(dim*0.15,0.9,0.5);
  buffer.stroke(1);
  theta+=0.001;
  
  dim = ease(dim, input.mix.level (), easing) * dim_multiplier + dim_addition;
  // println("dim: " + dim);
  // dim = log(map(dim,0,1,0,1000));
  // lines
  for(int i = 1; i<=numLines; i++) {
    buffer.strokeWeight(1);
    
  }
  
  move_points();
  // triangles
  // int triangleHeight = 300 / numTriangles;
  for (int i = 1; i<numLines; i++) {
    buffer.strokeWeight(1);
    buffer.stroke(0.8);
    // lineBase is the PVector for the lower end point of a line / lineTop for the higher end
    buffer.line(lineBase[i].x, lineBase[i].y, lineTop[i].x, lineTop[i].y);
  }
  draw_triangles();



  if (theta > 0.3)
    change_color_every_x_frames = 100 - (int)((theta-0.3)*100);
  if (change_color_every_x_frames < 20)  
    change_color_every_x_frames = 20;
    
  change_colors();
  get_band();
  // textausgabe
  buffer.fill(0);
  buffer.text("theta: " + round(theta,3), 4, 20); 
  buffer.text("dim: "+ round(dim,3), 4, 35); 
  buffer.text("peak: "+ round(ease_peak,3), 4,  50); 
  buffer.text("shift_multi: "+ round(shift_multi,5), 4,  65); 
  buffer.text("fps: " + round(frameRate,3), 4, 80); 
  
  beat.detect(input.mix);
  if ( beat.isOnset() ) {
    buffer.ellipse(15, 100, 10, 10);
  }
  
    server.sendScreen();
  buffer.endDraw();
  if (frameCount % 20 == 0)
    dust(45,1.7);
  background_buffer.endDraw();

  tint(1);
  image(background_buffer, 0, 0); 
  tint(1, 0.5);
  //image(buffer, 0, 0); 
  // image(buffer, dim*200, 0); 
  //  image(buffer, 0, dim*200); 
    
}
