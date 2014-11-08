class Positron extends Particle {
  // May not need anything much added besides the right sprite.
  Positron (float x, float y, float vx, float vy){
    super (x,y,vx,vy);
    this.sprite[0]=loadImage("positron.png");
    this.charge=1;
  }
}
