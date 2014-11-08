class Electron extends Particle {
  // May not need anything much added besides the right sprite.
  Electron (float x, float y, float vx, float vy){
    super (x,y,vx,vy);
    this.sprite[0]=loadImage("electron.png");
    this.charge=-1;
  }
}
