class Particle {
  PVector position;
  PVector velocity;
  PImage[] sprite;
  float mass;
  int charge;
  boolean linkedIn=false;
  //float x, y, vx, vy;
  Particle (float x, float y, float vx, float vy){
    this.position=new PVector (x, y);
    this.velocity=new PVector (vx, vy);
    this.sprite=new PImage[1];
    this.sprite[0]=loadImage("default.gif");
  }
  void updatePosition(){
    position.add(velocity);
    //float distFromCentre=mag(this.position.x,this.position.y);
    if (linkedIn) {
      position.add(new PVector(-position.y/500, position.x/500));
      velocity.mult(damping); // It may make more sense to apply damping once per linked particle elsewhere
    }
       
    //println("x: "+position.x+" y: "+position.y+" vx: "+velocity.x+" vy: "+velocity.y);
    if (abs(position.x)>width*5/8||abs(position.y)>height*5/8) {
      println("doom time! x="+position.x+", y="+position.y);
      nucleons.remove(this);
    }
  }
  
  void drawSprite(){
    image(sprite[0].get(), position.x, position.y, 30, 30);
  }
}
