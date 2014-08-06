class Nucleon extends Particle { // It's possible this should be an interface
  int happiness; // Too many protons on the dancefloor?
  boolean fixed=false;
  Nucleon (float x, float y, float vx, float vy) {
    super (x, y, vx, vy);
  }
  void attract (Nucleon that) {
    if (PVector.dist(this.position, that.position)<4*(nucleonDiameter)) {
      int totalCharge=this.charge+that.charge;
      //println("beginning attract function");
      /** This will be called on each bond each time-step, 
       and update the velocities of the two particles based on the distance between them.
       This is something like +a/r^12-b/r^6 I think. */
      float distance=dist(this.position.x, this.position.y, that.position.x, that.position.y);
      //println("distance calculated");
      float magnitude=nuclearRepulsion*pow(distance/nucleonDiameter, -8)-nuclearAttraction[totalCharge]*pow(distance/nucleonDiameter, -3);
      //println("magnitude calculated");
      PVector force=(PVector.sub(this.position, that.position));//.heading();
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
      //println("Attracting: Particle 1 at "+particle1.velocity.x+", "+particle1.velocity.y+" and 2 at "+particle2.velocity.x+", "+particle2.velocity.y);
    }
  }
}

