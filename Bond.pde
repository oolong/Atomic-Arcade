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
    /** This will be called on each bond each time-step, 
    and update the velocities of the two particles based on the distance between them.
    This is something like +a/r^12-b/r^6 I think. */
    float distance=dist(particle1.position.x, particle1.position.y, particle2.position.x, particle2.position.y);
    float magnitude=a*pow(distance/20,-6)+b*pow(distance/20,-2);
    float angle=(PVector.sub(particle1.position,particle2.position)).heading();
    PVector force=PVector.fromAngle(angle);
    force.mult(magnitude);
    particle1.velocity.add(force);
    particle2.velocity.sub(force);
    println("Attracting: Particle 1 at "+particle1.velocity.x+", "+particle1.velocity.y+" and 2 at "+particle2.velocity.x+", "+particle2.velocity.y);
  }
  
}
