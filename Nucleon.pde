class Nucleon extends Particle { // It's possible this should be an interface
  boolean fixed=false;
  int mood, moodTime;
  Nucleon (float x, float y, float vx, float vy) {
    super (x, y, vx, vy);
    mood=WHEEE;
    moodTime=200;
  }

  void attract (Nucleon that) {
    //float distance=PVector.dist(this.position, that.position)/nucleonDiameter;
    PVector diff=PVector.sub(this.position, that.position);
    float distSq=(sq(diff.x)+sq(diff.y))/sq(nucleonDiameter);
    //text(distSq, 100,100);
    //text(sq(nucleonDiameter), 100,120);
    if (distSq<16) {
      if (this.linkedIn==true||that.linkedIn==true) {
        this.linkedIn=true;
        that.linkedIn=true;
      }
      if (distSq>0.6) {            
        int totalCharge=this.charge+that.charge;
        //println("beginning attract function");
        /** This will be called on each bond each time-step, 
         and update the velocities of the two particles based on the distance between them.
         This is something like +a/r^12-b/r^6 I think. */
        //println("distance calculated");
        float magnitude=nuclearRepulsion/sq(sq(distSq))-nuclearAttraction[totalCharge]/sq(distSq);
        //println("magnitude calculated");
        PVector force=diff;//(PVector.sub(this.position, that.position));//.heading();
        //println("angle calculated");
        //PVector force=PVector.fromAngle(angle);
        //println("force created");
        //println("force has magnitude "+force.mag()+" but it should be "+magnitude);
        //println("force has angle "+force.heading());
        force.normalize();
        force.mult(magnitude);
        //println("magnitude set");
        this.velocity.add(force);
        that.velocity.sub(force);
        if (magnitude>0.5) { // Express slight concern about bouncing
          this.mood=FROWN;
          that.mood=FROWN;
          this.moodTime=10;
          that.moodTime=10;
          if (this.mood!=FROWN){
            this.velocity.mult(0.5);
            that.velocity.mult(0.5);
          }
        }
        //println("Attracting: Particle 1 at "+particle1.velocity.x+", "+particle1.velocity.y+" and 2 at "+particle2.velocity.x+", "+particle2.velocity.y);
      } else {
        PVector collisionPoint=new PVector((this.position.x+that.position.x)/2, (this.position.y+that.position.y)/2);
        PVector thisVector=PVector.sub(this.position, collisionPoint);
        float thisDistance=thisVector.mag();
        this.position.add(PVector.mult(thisVector, (nucleonDiameter-thisDistance)/(2*nucleonDiameter)));
        that.position.sub(PVector.mult(thisVector, (nucleonDiameter-thisDistance)/(2*nucleonDiameter)));
      }
    }
  }
  void drawSprite() {
    image(sprite[mood].get(), position.x, position.y, 30, 30);
  }
}
