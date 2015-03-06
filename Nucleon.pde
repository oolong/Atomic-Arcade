class Nucleon extends Particle { // It's possible this should be an interface
  boolean fixed=false;
  int mood, moodTime, doomLevel=0;
  float diameter;
  Nucleon (float x, float y, float vx, float vy) {
    super (x, y, vx, vy);
    mood=WHEEE; // A split second's excitement on entry
    moodTime=200;
    diameter=nucleonDiameter;
    int i=0;
    this.baryonNumber=1;
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
      attractionMultiplier=1.8;
      //printIfDebugging("BYEBYE FORCE");
    }
    if (this.mood==OHNOEZ | that.mood==OHNOEZ) {
      attractionMultiplier*=0.8;
    }

    if (distSq<10) {
      if ((this.linkedIn==true||that.linkedIn==true)&&distSq<4) { // Only counts if they've slowed down
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
        if (magnitude>0.5 && attractionMultiplier==-1 && this.mood!=OHNOEZ && this.mood!=BYEBYE) { // Express slight concern about bouncing
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
    image(sprite[mood], position.x, position.y);
  }
  void drawShadow() {
    noStroke();
    fill(0, 64);
    ellipse(position.x-5, position.y+5, 36, 36);
  }
  void updatePosition() {
    super.updatePosition();
    if (this.mood==OHNOEZ && this!=protonOne) {
      this.position.x+=vibrate;
      vibrate*=-1;
      if (decayTypes[atomicNumber][neutrons]==POSITRON || decayTypes[atomicNumber][neutrons]==ELECTRON) { // Beta decay
        if (random(0,1)>0.5){
          this.sprite=neutronImages;
        }
        else {
          this.sprite=protonImages;
        }
      }
    }
  }
}

