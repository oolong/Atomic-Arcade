class Particle {
  PVector position;
  PVector velocity;
  PImage[] sprite;
  float mass;
  //float x, y, vx, vy;
  Particle (float x, float y, float vx, float vy){
    this.position=new PVector (x, y);
    this.velocity=new PVector (vx, vy);
    this.sprite=new PImage[1];
    this.sprite[0]=loadImage("default.png");
  }
  void updatePosition(){
    position.add(velocity);
    //println("x: "+position.x+" y: "+position.y+" vx: "+velocity.x+" vy: "+velocity.y);
  }
  
  void drawSprite(int frame){
    image(sprite[frame], position.x, position.y, 40, 40);
  }
}
