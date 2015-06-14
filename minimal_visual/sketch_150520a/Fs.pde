
void paper(int in_val) {
  noStroke();
  float inHsb = map(in_val, 0,255,0,1);
  
  //small dust
  for (int i = 0; i<width-1; i+=2) {
    for (int j = 0; j<height-1; j+=2) {
      //fill(random(235-40, 235+30), in_val-2);
      //HSB:
      fill(random(0.76, 1), inHsb*min(dim+0.5,2.0));
      rect(i, j, 2, 2);
    }
  }
 
 // large dust
  for (int i = 0; i<20; i++) {
    //fill(random(30, 170), random(in_val*2.5, in_val*5));
    fill(random(0.42, 0.76), random(inHsb*2.5, inHsb*5));
    rect(random(0, width-2), random(0, height-2), random(1, 4), random(1, 4));
  }
}
    
    
float ease(float value, float target, float easingVal) {
        float d = target - value;
        if (abs(d)>0.001) value+= d*easingVal;
        return value;
}
