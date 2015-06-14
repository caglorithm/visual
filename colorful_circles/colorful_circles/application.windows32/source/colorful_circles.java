import processing.core.*; 
import processing.data.*; 
import processing.opengl.*; 

import processing.opengl.*; 
import ddf.minim.*; 
import ddf.minim.signals.*; 
import ddf.minim.analysis.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class colorful_circles extends PApplet {

float easing =  0.4f;
float dim = 0;

int sz = 500;
float h, w;

float theta = 0;

PFont font;  

// circle color matrix
int co = 2;
int ro = 2;
int[][] cols;
float[][] mode;

int xrand = 0;
int yrand = 0;

float alph = 0;

public void setup() {
  font = loadFont("letter20.vlw");
  textFont(font, 14); 
  
  size (sz, sz, P2D);
  frameRate(60);
  //ellipseMode(CENTER);
  colorMode(HSB, 1);
  //stroke(255);
  strokeWeight(0.1f);
  noFill();
  smooth();
  h = height /2; w = width /2;
  
  minim = new Minim (this);
  input = minim.getLineIn (Minim.STEREO, 1024*4);
  fft = new FFT (input.bufferSize (), 
                 input.sampleRate ());
  //fft.logAverages(11, 16);
  
  
  // circle color matrix
  cols = new int[co][ro];
  for (int i = 0; i < co; i++) {
    for (int j = 0; j < ro; j++) {
      cols[i][j] = color(random(1));
    }
  }
}


public void draw () {
  strokeWeight(0.01f);
  theta += 0.001f;
  if (theta > 1) theta = 0;

  if (theta < 0.9f || dim < 0.5f)
    background(0.01f, 0.01f, 0.1f);
  /*else
    background(1,0.7);*/
    
  dim = ease(dim, input.mix.level () * 10, easing);


  float ease_peak = 0;
  ease_peak = ease(ease_peak, peak, 0.1f);
  ease_peak = map(ease_peak, 0, 300, 0, 1);
  
  ease_peak = -ease_peak + 1;
  
  // create color matrix
  int nequal = 0;
  float oldcol = cols[xrand][yrand];
  //------------ main color
  cols[xrand][yrand] = color(ease_peak,ease_peak, 0.5f, alph);
  for (int i = 0; i < co; i++) {
    for (int j = 0; j < ro; j++) {
      //cols[i][j] = ease_peak;
      if (cols[i][j] == oldcol) {
        nequal++;
        cols[i][j] = cols[xrand][yrand];
        //println("schon " + i + " " + j);

      }
      else if (i != xrand || j != yrand){ 
        //----------- alternate color
        cols[i][j] = color(0.5f,ease_peak,0.8f*ease_peak, alph);
        //println("not " + i + " " + j);
        if (random(1) < 0.01f) {
          cols[i][j] = cols[xrand][yrand]; 
          //println (i + " " + j + " switch");
        }
      }
    }
  }
          //println("n= "+nequal);

    // wenn alle gleich sind, wieder einen random setzen
    if (nequal > (co*ro)-1 && random(1) < 0.005f) {
    xrand = 0; 
    yrand = 0;
    if (random(1)>0.5f)
       xrand = 1;
    if (random(1)>0.5f) 
       yrand = 1;
     cols[xrand][yrand] = color(random(1)); 
     //println("all equal");  
    }
  
  //}
  
  //println("rand " + xrand+ " " +yrand);
  if (alph < 0.7f) alph+=0.0001f ;

  dust(35, dim);  
   
  // outer circle have stroke if all are the same
   /*if ( random(1)-alph<0.5) noStroke();
      else*/ 
  if (nequal == 4 && random(1)>0.3f && dim > 0.4f) {
  stroke(dim*100, alph*20); strokeWeight((dim-alph)*5); }
  
  // --- \u00e4u\u00dferen kreise
  drawCircle(cols[0][0], 10*dim+2,alph, 100,100);
  drawCircle(cols[0][1], 10*dim+2,alph, -100,100);
  drawCircle(cols[1][0], 10*dim+2,alph, 100,-100);
  drawCircle(cols[1][1], 10*dim+2,alph, -100,-100);

  // STROKE f\u00fcr die inneren kreise
  if (random(1)-alph<0.5f) noStroke();
      else {stroke(dim*100, alph*10); strokeWeight((dim-alph));}
      
  // -------- inneren kreise
  float alph2 = theta;
  if (alph2 > 0.4f) alph2 = 0.4f;
  
  drawCircle(color(0.51f,1,0.5f,alph2), 100*dim+2, alph2, 0,0);
  drawCircle(color(0.21f,0.8f,0.5f,alph2), 100*dim+2, alph2,0,0);
  drawCircle(color(0.91f,0.5f,0.5f,alph2), 100*dim+2, alph2,0,0);
  

  // glitzer on the circles
  pushMatrix();
  translate(w,h);
  for (int i = 0; i<30; i++) {
    //fill(random(0.12, 0.66), random(inHsb*2.5, inHsb*5));
    fill(theta,random(0,1),1);
    float x = cos(random(0,TWO_PI)) * random(50 * dim,200 * dim);
    float y = sin(random(0,TWO_PI)) * random(50 * dim,200 * dim);
    rect(x, y, random(1, 3), random(1, 3));
  }
  popMatrix();
  
  // textausgabe
  DecimalFormat df = new DecimalFormat("#.###");
  text("theta: "+ df.format(theta), 4, 20); 
  text("dim: "+ df.format(dim), 4, 35); 
  text("peak: "+ df.format(ease_peak), 4,  50); 
  text("alph: "+ df.format(alph), 4,  65); 
  if (frameCount % 2 == 0)
    get_band();
}


public void drawCircle(int coll, /*float hsb_1, float hsb_2,*/ float rand, float alphi, int _x, int _y) {
  pushMatrix();
  translate(w+random(-rand,rand)+_x,h+random(-rand,rand)+_y);
    fill(coll /*hsb_1,hsb_2,0.5,alphi*/);
    ellipse(0,0,200,200);
  popMatrix();
}




  
Minim minim;
AudioInput input;
AudioOutput out;
FFT fft;

float peak = 0;

public float ease(float value, float target, float easingVal) {
        float d = target - value;
        if (abs(d)>0.001f) value+= d*easingVal;
        return value;
}

public void dust(int in_val, float small_amp) {
  noStroke();
  float inHsb = map(in_val, 0,255,0,1);
  
  //small dust
  for (int i = 0; i<width-1; i+=2) {
    for (int j = 0; j<height-1; j+=2) {
      //fill(random(235-40, 235+30), in_val-2);
      //HSB:
      fill(random(0.76f, 1), inHsb*small_amp);
      rect(i, j, 2, 2);
    }
  }
 
 // large dust
  for (int i = 0; i<30; i++) {
    //fill(random(30, 170), random(in_val*2.5, in_val*5));
    fill(random(0.12f, 0.66f), random(inHsb*2.5f, inHsb*5));
    rect(random(0, width-2), random(0, height-2), random(1, 3), random(1, 3));
  }
}


  
public float[] get_band(){
      
  float g = 0;    // Gr\u00c3\u00bcnwert der F\u00c3\u00bcllfarbe
  float h = 0;    // H\u00c3\u00b6he von Rechteck und Linie
  float one = 0;
  int maxfreq = 3000;
  int maxamp = 80;
  float lastone=0;

  
  float[] band = new float[maxfreq];
  //println(fft.specSize());
  
  float specStep; // Breite einer horiz. Linie
  float specScale = (float) width / (fft.specSize () - 1);
  
  // Erzeugen der 'Frequenz-Gruppen' (16 Bereich)
  // m\u00c3\u00b6gliche Schritte: 2-4-8-16-32-64-128
  //float[] group = getGroup (32);
  fft.forward (input.mix);  

  // Zeichnen des detailierten Frequenzspektrums
  noStroke ();
    for (int i = 0; i < maxfreq; i++) {
    //g = map (fft.getBand (i), 0, maxSpec, 50, 255);
    //h = map (fft.getBand (i), 0, maxSpec, 2, height);
    //one = map (fft.getBand (i), 0, maxSpec, 0, 1);
    float freq = fft.getFreq(i);

    //freq = log(freq)/log(1.2);
    
    g = map(freq,0,maxamp,100,255);
    h = map(freq,0,maxamp,2,height);
    one = map(freq,0,maxamp,0,1);
    
    //fill (0, g, 0);
    //rect (i * specScale, height - h, specScale, h);
    if (one>0){
          band[i]=one;
          if (one>0.1f && one > lastone){
            peak = i;
            lastone = one;
          }
    } 
 }
 
     // average colors from the band[] 
    
      /// ******** TEXT DRAWING *******
/*  fill (255);  
  font = loadFont("letter20.vlw");
  textFont(font);
*/
  
  // new line signal    
  return band;
 }
 
 /*
 float getPeak() {
     int maxamp = 80;
     float one;
     int maxfreq = 3000;
     float[] band = new float[maxfreq];
     float peak;
  for (int i = 0; i < 10000; i++) {
    //g = map (fft.getBand (i), 0, maxSpec, 50, 255);
    //h = map (fft.getBand (i), 0, maxSpec, 2, height);
    //one = map (fft.getBand (i), 0, maxSpec, 0, 1);
    float freq = fft.getFreq(i);
    //freq = log(freq)/log(1.2);
    
    one = map(freq,0,maxamp,0,1);
    
    if (one>0){
          band[i]=one;
          if (one>0.1 && one > lastone){
            peak = i;
            lastone = one;
          }
    }
  }
   return peak;
 }*/
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "colorful_circles" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
