class Particle {
  PVector position;
  PVector velocity;
  PImage[] sprite;
  float mass;
  int charge;
  //float x, y, vx, vy;
  Particle (float x, float y, float vx, float vy){
    this.position=new PVector (x, y);
    this.velocity=new PVector (vx, vy);
    this.sprite=new PImage[1];
    this.sprite[0]=loadImage("default.gif");
  }
  void updatePosition(){
    position.add(velocity);
    //println("x: "+position.x+" y: "+position.y+" vx: "+velocity.x+" vy: "+velocity.y);
    if (abs(position.x)>width*5/8||abs(position.y)>height*5/8) {
      println("doom time! x="+position.x+", y="+position.y);
      particles.remove(this);
    }
  }
  
  void drawSprite(int frame){
    image(sprite[frame].get(), position.x, position.y, 33, 33);
  }
}
