class Blob {
  float midx, midy, midz;
  float x, y, z;
  float angle, radius;
  color col;
  
  Blob(float xpos, float ypos, float zpos, float thisangle, float thisradius){
    midx=xpos;
    midy=ypos;
    midz=zpos;
    angle=thisangle;
    radius=thisradius;
  }
  private void update() {
    // animation engine
    fill(white);
    angle+=0.001;
    x = midx + radius * cos(angle);
    y = midy + radius * sin(angle);
    z = midz +log(dim+1)*midz/10;
    
   //if (random(0,1)>0.8)
   //   updateColor(color(dim*0.3,0.9,0.9));
  }
  void draw() {
    update();
    pushMatrix();
      translate(x,y,z);
      box(5,5,5);
    popMatrix();
  }
  
  private void updateColor(color thiscol) {
    col = thiscol;
    fill(col);
  }
}
