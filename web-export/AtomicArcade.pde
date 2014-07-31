
ArrayList<Particle> particles;
ArrayList<Bond> bonds;

void setup () {
  size(400,400);
  particles=new ArrayList<Particle>();
  bonds=new ArrayList<Bond>();
  particles.add(new Proton(200,200,0,0.1)); // Starting with a static hydrogen atom?
  particles.add(new Neutron(200-40,200,0,-0.1)); // Starting with a static hydrogen atom?
  // We'll also need to create the UI here, of course
  bonds.add(new Bond((Nucleon)particles.get(0),(Nucleon)particles.get(1)));
  background (0);
}

void draw () {
  /* Modelling bit will consist of:
   * looping over all plausible combinations of nucleons to see if we need to 
   * looping over all of the protons and repelling them from each other
   * looping over the bonds
   * adjusting all velocities
   * adjusting all positions
   */
   
   /* Open questions for the model - should all particles be attracted to the centre?
    *  Or should the viewport be drawn towards the centre of mass?
    *  Do we need something like drag on the particles?
    */
   
   //background (0);
   fill (0, 6);
   rect (0, 0, width, height);
   for (int i=0; i<particles.size(); i++){ // Bond-updating loop
     Particle thisParticle=particles.get(i);
     if (thisParticle instanceof Neutron || thisParticle instanceof Proton){
       // Loop over all the other nucleons it hasn't already been checked against
     }
   }
     
   for (int i=0; i<bonds.size(); i++){
     bonds.get(i).attract();
   }
   
   for (int i=0; i<particles.size(); i++){ // Position-updating loop
     particles.get(i).updatePosition();
   }
   
   for (int i=0; i<particles.size(); i++){ // Particle-drawing loop
     particles.get(i).drawSprite(0);
   }
}
  
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
class Electron extends Particle {
  // May not need anything much added besides the right sprite.
  Electron (float x, float y, float vx, float vy){
    super (x,y,vx,vy);
    this.sprite[0]=loadImage("electron.gif");
  }
}
class Neutron extends Nucleon {
  Neutron (float x, float y, float vx, float vy){
    super (x, y, vx, vy);
    this.sprite[0]=loadImage("neutron.gif");
  }
}  
class Nucleon extends Particle { // It's possible this should be an interface
  int happiness; // Too many protons on the dancefloor?
  Nucleon (float x, float y, float vx, float vy){
    super (x,y,vx,vy);
  }
}
class Particle {
  PVector position;
  PVector velocity;
  PImage[] sprite;
  float mass;
  //float x, y, vx, vy;
  Particle (float x, float y, float vx, float vy){
    this.position=new PVector (x, y);
    this.velocity=new PVector (vx, vy);
    this.sprite=new PImage[1];
    this.sprite[0]=loadImage("default.png");
  }
  void updatePosition(){
    position.add(velocity);
    //println("x: "+position.x+" y: "+position.y+" vx: "+velocity.x+" vy: "+velocity.y);
  }
  
  void drawSprite(int frame){
    image(sprite[frame], position.x, position.y, 40, 40);
  }
}
class Proton extends Nucleon {
  Proton (float x, float y, float vx, float vy){
    super (x, y, vx, vy);
    this.sprite[0]=loadImage("proton.gif");
  }
  void repel (Proton otherProton){
    // calculate distance and angle, alter velocities
  }
}

