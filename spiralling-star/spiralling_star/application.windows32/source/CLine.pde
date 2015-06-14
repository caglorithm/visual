
class CLine {
  
  float vx, vy, thick, wobble=0;
  float theta = 0;
  
  CLine(float _vx ,float _vy,float _thick) {
    vx = _vx;
    vy = _vy;
    thick = _thick;
  }
  
  void draw() {
    theta+=0.01;
    strokeWeight(thick);
    noFill();
    
    beginShape();
      curveVertex(20,vy);
      curveVertex(20,vy);
      
      //curveVertex(w, vy-map(sin(theta*TWO_PI),-1,1,0,40));
      curveVertex(w-30, vy+map(sin(theta*TWO_PI+PI*theta),-1,1,0,30));  
      curveVertex(w+10, vy+map(sin(theta*TWO_PI+PI*theta),-1,1,0,40));         
      curveVertex(w+30, vy+map(sin(theta*TWO_PI+PI*theta),-1,1,0,30));  
      curveVertex(width-20, vy);      
      
      curveVertex(width-20, vy);      

    endShape();
  }
  
  
}
