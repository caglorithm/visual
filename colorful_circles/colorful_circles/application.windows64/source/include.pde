import processing.opengl.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
  
Minim minim;
AudioInput input;
AudioOutput out;
FFT fft;

float peak = 0;

float ease(float value, float target, float easingVal) {
        float d = target - value;
        if (abs(d)>0.001) value+= d*easingVal;
        return value;
}

void dust(int in_val, float small_amp) {
  noStroke();
  float inHsb = map(in_val, 0,255,0,1);
  
  //small dust
  for (int i = 0; i<width-1; i+=2) {
    for (int j = 0; j<height-1; j+=2) {
      //fill(random(235-40, 235+30), in_val-2);
      //HSB:
      fill(random(0.76, 1), inHsb*small_amp);
      rect(i, j, 2, 2);
    }
  }
 
 // large dust
  for (int i = 0; i<30; i++) {
    //fill(random(30, 170), random(in_val*2.5, in_val*5));
    fill(random(0.12, 0.66), random(inHsb*2.5, inHsb*5));
    rect(random(0, width-2), random(0, height-2), random(1, 3), random(1, 3));
  }
}


  
float[] get_band(){
      
  float g = 0;    // GrÃ¼nwert der FÃ¼llfarbe
  float h = 0;    // HÃ¶he von Rechteck und Linie
  float one = 0;
  int maxfreq = 3000;
  int maxamp = 80;
  float lastone=0;

  
  float[] band = new float[maxfreq];
  //println(fft.specSize());
  
  float specStep; // Breite einer horiz. Linie
  float specScale = (float) width / (fft.specSize () - 1);
  
  // Erzeugen der 'Frequenz-Gruppen' (16 Bereich)
  // mÃ¶gliche Schritte: 2-4-8-16-32-64-128
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
          if (one>0.1 && one > lastone){
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
