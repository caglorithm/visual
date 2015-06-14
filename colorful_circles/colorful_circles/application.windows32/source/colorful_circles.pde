float easing =  0.4;
float dim = 0;

int sz = 500;
float h, w;

float theta = 0;

PFont font;  

// circle color matrix
int co = 2;
int ro = 2;
color[][] cols;
float[][] mode;

int xrand = 0;
int yrand = 0;

float alph = 0;

void setup() {
  font = loadFont("letter20.vlw");
  textFont(font, 14); 
  
  size (sz, sz, P2D);
  frameRate(60);
  //ellipseMode(CENTER);
  colorMode(HSB, 1);
  //stroke(255);
  strokeWeight(0.1);
  noFill();
  smooth();
  h = height /2; w = width /2;
  
  minim = new Minim (this);
  input = minim.getLineIn (Minim.STEREO, 1024*4);
  fft = new FFT (input.bufferSize (), 
                 input.sampleRate ());
  //fft.logAverages(11, 16);
  
  
  // circle color matrix
  cols = new color[co][ro];
  for (int i = 0; i < co; i++) {
    for (int j = 0; j < ro; j++) {
      cols[i][j] = color(random(1));
    }
  }
}


void draw () {
  strokeWeight(0.01);
  theta += 0.001;
  if (theta > 1) theta = 0;

  if (theta < 0.9 || dim < 0.5)
    background(0.01, 0.01, 0.1);
  /*else
    background(1,0.7);*/
    
  dim = ease(dim, input.mix.level () * 10, easing);


  float ease_peak = 0;
  ease_peak = ease(ease_peak, peak, 0.1);
  ease_peak = map(ease_peak, 0, 300, 0, 1);
  
  ease_peak = -ease_peak + 1;
  
  // create color matrix
  int nequal = 0;
  float oldcol = cols[xrand][yrand];
  //------------ main color
  cols[xrand][yrand] = color(ease_peak,ease_peak, 0.5, alph);
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
        cols[i][j] = color(0.5,ease_peak,0.8*ease_peak, alph);
        //println("not " + i + " " + j);
        if (random(1) < 0.01) {
          cols[i][j] = cols[xrand][yrand]; 
          //println (i + " " + j + " switch");
        }
      }
    }
  }
          //println("n= "+nequal);

    // wenn alle gleich sind, wieder einen random setzen
    if (nequal > (co*ro)-1 && random(1) < 0.005) {
    xrand = 0; 
    yrand = 0;
    if (random(1)>0.5)
       xrand = 1;
    if (random(1)>0.5) 
       yrand = 1;
     cols[xrand][yrand] = color(random(1)); 
     //println("all equal");  
    }
  
  //}
  
  //println("rand " + xrand+ " " +yrand);
  if (alph < 0.7) alph+=0.0001 ;

  dust(35, dim);  
   
  // outer circle have stroke if all are the same
   /*if ( random(1)-alph<0.5) noStroke();
      else*/ 
  if (nequal == 4 && random(1)>0.3 && dim > 0.4) {
  stroke(dim*100, alph*20); strokeWeight((dim-alph)*5); }
  
  // --- äußeren kreise
  drawCircle(cols[0][0], 10*dim+2,alph, 100,100);
  drawCircle(cols[0][1], 10*dim+2,alph, -100,100);
  drawCircle(cols[1][0], 10*dim+2,alph, 100,-100);
  drawCircle(cols[1][1], 10*dim+2,alph, -100,-100);

  // STROKE für die inneren kreise
  if (random(1)-alph<0.5) noStroke();
      else {stroke(dim*100, alph*10); strokeWeight((dim-alph));}
      
  // -------- inneren kreise
  float alph2 = theta;
  if (alph2 > 0.4) alph2 = 0.4;
  
  drawCircle(color(0.51,1,0.5,alph2), 100*dim+2, alph2, 0,0);
  drawCircle(color(0.21,0.8,0.5,alph2), 100*dim+2, alph2,0,0);
  drawCircle(color(0.91,0.5,0.5,alph2), 100*dim+2, alph2,0,0);
  

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


void drawCircle(color coll, /*float hsb_1, float hsb_2,*/ float rand, float alphi, int _x, int _y) {
  pushMatrix();
  translate(w+random(-rand,rand)+_x,h+random(-rand,rand)+_y);
    fill(coll /*hsb_1,hsb_2,0.5,alphi*/);
    ellipse(0,0,200,200);
  popMatrix();
}
