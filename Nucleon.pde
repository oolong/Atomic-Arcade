class Nucleon extends Particle { // It's possible this should be an interface
  boolean fixed=false;
  int mood, moodTime;
  float diameter;
  float vibrate=2;
  Nucleon (float x, float y, float vx, float vy) {
    super (x, y, vx, vy);
    mood=WHEEE; // A split second's excitement on entry
    moodTime=200;
    diameter=nucleonDiameter;
    int i=0;
    boolean replacement=false;
    while (i<nucleonCount) {
      if (!nucleons[i].active) {
        replacement=true;
        nucleons[i]=this;
        break;
      }
      i++;
    }
    if (!replacement) {
      nucleons[nucleonCount]=this;
      nucleonCount++;
    }
  }

  void attract (Nucleon that) {
    //float distance=PVector.dist(this.position, that.position)/this.diameter;
    PVector diff=PVector.sub(this.position, that.position);
    float distSq=(sq(diff.x)+sq(diff.y))/sq(this.diameter);
    //text(distSq, 100,100);
    //text(sq(this.diameter), 100,120);
    float attractionMultiplier=-1;
    if (this.mood==BYEBYE ^ that.mood==BYEBYE) { // If one of these particles is going byebye, repel it
      attractionMultiplier=1;
      //printIfDebugging("BYEBYE FORCE");
    }
    if (this.mood==OHNOEZ | that.mood==OHNOEZ) {
      attractionMultiplier*=0.8;
    }

    if (distSq<10) {
      if (this.linkedIn==true||that.linkedIn==true) {
        this.linkedIn=true;
        that.linkedIn=true;
      }
      if (distSq>0.6) {            
        int totalCharge=this.charge+that.charge;
        //printIfDebugging("beginning attract function");
        /** This will be called on each bond each time-step, 
         and update the velocities of the two particles based on the distance between them.
         This is something like +a/r^12-b/r^6 I think. */
        //printIfDebugging("distance calculated");
        float magnitude=nuclearRepulsion/sq(sq(distSq))+attractionMultiplier*nuclearAttraction[totalCharge]/sq(distSq);
        //printIfDebugging("magnitude calculated");
        PVector force=diff;//(PVector.sub(this.position, that.position));//.heading(); // Force is a vector in the same direction as the difference between the particles...
        //printIfDebugging("angle calculated");
        //PVector force=PVector.fromAngle(angle);
        //printIfDebugging("force created");
        //printIfDebugging("force has magnitude "+force.mag()+" but it should be "+magnitude);
        //printIfDebugging("force has angle "+force.heading());
        force.normalize();
        force.mult(magnitude);
        //printIfDebugging("magnitude set");
        this.velocity.add(force);
        that.velocity.sub(force);
        if (magnitude>0.5 && attractionMultiplier==-1 && this.mood!=OHNOEZ) { // Express slight concern about bouncing
          if (this.mood!=FROWN) {
            this.velocity.mult(0.5);
            that.velocity.mult(0.5);
          }
          this.mood=FROWN;
          that.mood=FROWN;
          this.moodTime=10;
          that.moodTime=10;
        }
        //printIfDebugging("Attracting: Particle 1 at "+particle1.velocity.x+", "+particle1.velocity.y+" and 2 at "+particle2.velocity.x+", "+particle2.velocity.y);
      }
      else { // distSq<0.6
        PVector collisionPoint=new PVector((this.position.x+that.position.x)/2, (this.position.y+that.position.y)/2);
        PVector thisVector=PVector.sub(this.position, collisionPoint);
        float thisDistance=thisVector.mag();
        this.position.add(PVector.mult(thisVector, (this.diameter-thisDistance)/(2*this.diameter)));
        that.position.sub(PVector.mult(thisVector, (this.diameter-thisDistance)/(2*this.diameter)));
      }
    }
  }
  void drawSprite() {
    //printIfDebugging("Mood="+mood);
    image(sprite[mood], position.x, position.y, 30, 30);
  }
  void drawShadow() {
    noStroke();
    fill(0, 64);
    ellipse(position.x-5, position.y+5, 27, 27);
  }
  void updatePosition() {
    super.updatePosition();
    if (this.mood==OHNOEZ && this!=protonOne) {
      this.position.x+=vibrate;
      vibrate=-vibrate;
    }
  }
}

