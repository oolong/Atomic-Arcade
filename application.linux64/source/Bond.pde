/** Representing the strong nuclear force between two particles (probably invisibly). */
class Bond {
  Nucleon particle1;
  Nucleon particle2;
  float a=0.1, b=-0.2;
  
  Bond(Nucleon particle1, Nucleon particle2){
    this.particle1=particle1;
    this.particle2=particle2;
  }
  
  void attract (){
    //println("beginning attract function");
    /** This will be called on each bond each time-step, 
    and update the velocities of the two particles based on the distance between them.
    This is something like +a/r^12-b/r^6 I think. */
    float distance=dist(particle1.position.x, particle1.position.y, particle2.position.x, particle2.position.y);
    //println("distance calculated");
    float magnitude=a*pow(distance/40,-6)+b*pow(distance/40,-2);
    //println("magnitude calculated");
    PVector force=(PVector.sub(particle1.position,particle2.position));//.heading();
    //println("angle calculated");
    //PVector force=PVector.fromAngle(angle);
    //println("force created");
    //println("force has magnitude "+force.mag()+" but it should be "+magnitude);
    //println("force has angle "+force.heading());
    force.normalize();
    force.mult(magnitude);
    //println("magnitude set");
    
    if (particle1.fixed!=true) {
      particle1.velocity.add(force);
    }
    if (particle2.fixed!=true) {
      particle2.velocity.sub(force);
    }
    //println("Attracting: Particle 1 at "+particle1.velocity.x+", "+particle1.velocity.y+" and 2 at "+particle2.velocity.x+", "+particle2.velocity.y);
  }
  
}
