class Proton extends Nucleon {
  Proton (float x, float y, float vx, float vy){
    super (x, y, vx, vy);
    this.sprite[0]=loadImage("proton.gif");
  }
  void repel (Proton otherProton){
    // calculate distance and angle, alter velocities
  }
}
