class Proton extends Nucleon {
  Proton (float x, float y, float vx, float vy){
    super (x, y, vx, vy);
    this.sprite[0]=loadImage ("proton.gif");
    this.charge=1;
  }
  void repel (Proton that){
    // calculate distance and angle, alter velocities
    float distance=dist (this.position.x, this.position.y, that.position.x, that.position.y);
    float magnitude=em*pow (distance/nucleonDiameter,-2);
    PVector force=(PVector.sub (this.position, that.position));//.heading();
    force.normalize();
    force.mult (magnitude);
    //println ("repelling by "+magnitude);
    if (this.fixed!=true) {
      this.velocity.add(force);
    }
    if (that.fixed!=true) {
      that.velocity.sub (force);
    }
    
  }
}
