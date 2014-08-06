/* @pjs preload="circle-32.png, circle-xxl.png, default.gif, default.png, neutron.gif, neutron1.png, proton.gif, proton1.png, proton2.png, proton3.png, proton4.png, proton5.png"; 
 */

ArrayList<Particle> particles;
ArrayList<Bond> bonds;
//ArrayList<Proton> protons;
float em=0.1; // Strength of the electromagnetic force
Particle ProtonOne;
float[] nuclearAttraction = { 
  0.1, 0.8, 0.01
};
float nuclearRepulsion = 0.8;
float nucleonDiameter = 30;

void setup () {
  size(1024, 768);
  particles=new ArrayList<Particle>();
  bonds=new ArrayList<Bond>();
  particles.add(new Proton(0, 0, 0, 0)); // Starting with a static hydrogen atom?
  /*  particles.add(new Neutron(-40,0,0,-0.2)); // Starting with a static hydrogen atom?
   particles.add(new Proton(0,30,0,0)); // Starting with a static hydrogen atom?
   particles.add(new Neutron(40,0,0,0)); // Starting with a static hydrogen atom?
   particles.add(new Proton(50,-40,0,0)); // Starting with a static hydrogen atom?
   particles.add(new Neutron(90,50,0,0)); // Starting with a static hydrogen atom?
   */  // We'll also need to create the UI here, of course
  /*bonds.add(new Bond((Nucleon)particles.get(0),(Nucleon)particles.get(1)));
   bonds.add(new Bond((Nucleon)particles.get(1),(Nucleon)particles.get(2)));
   bonds.add(new Bond((Nucleon)particles.get(2),(Nucleon)particles.get(3)));
   bonds.add(new Bond((Nucleon)particles.get(3),(Nucleon)particles.get(0)));
   bonds.add(new Bond((Nucleon)particles.get(3),(Nucleon)particles.get(1)));
   bonds.add(new Bond((Nucleon)particles.get(0),(Nucleon)particles.get(2)));
   //particles.get(0).fixed=true;
   */
  background (0);
  println("setup complete");
  ProtonOne=particles.get(0);
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
  translate(width/2, height/2);
  fill (0, 1);
  rect (-width/2, -height/2, width, height);

  //println("first loop through complete");

  for (int i=0; i<particles.size ()-1; i++) { // Loop through all possible pairs of particles, repel protons, update bonds
    Particle particle1=particles.get(i);
    for (int j=i+1; j<particles.size (); j++) {
      Particle particle2=particles.get(j);
      //checkBonds (particle1, particle2);
      if (particle1.charge * particle2.charge==1) { // Only happens if both particles are protons
        ((Proton)particle1).repel((Proton)particle2);
      }
      ((Nucleon)particle1).attract((Nucleon)particle2);
    }
  }

  /*for (int i=0; i<bonds.size(); i++){ // Bond-attraction loop
   bonds.get(i).attract();
   }*/
  //println("attractions complete");

  for (int i=0; i<particles.size (); i++) { // Position-updating loop
    particles.get(i).updatePosition();
  }
  //println("position-updating complete");

  for (int i=0; i<particles.size (); i++) { // Particle-drawing loop
    particles.get(i).drawSprite(0);
  }
  ProtonOne.position.mult(0.8);
  ProtonOne.velocity.mult(0.99);
}

void shootProton () {
  particles.add(new Proton (-width/2, -height/2, 3, 3*height/width));
}

void shootNeutron () {
  particles.add(new Neutron (width/2, -height/2, -3, 3*height/width));
}

void keyPressed() {
  if (key=='p') {
    println("key p pressed");
    shootProton();
  }
  if (key=='n') {
    println("key n pressed");
    shootNeutron();
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
class Electron extends Particle {
  // May not need anything much added besides the right sprite.
  Electron (float x, float y, float vx, float vy){
    super (x,y,vx,vy);
    this.sprite[0]=loadImage("electron.gif");
    this.charge=-1;
  }
}
class Neutron extends Nucleon {
  Neutron (float x, float y, float vx, float vy){
    super (x, y, vx, vy);
    this.sprite[0]=loadImage("neutron.gif");
    this.charge=0;
  }
}  
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

class Particle {
  PVector position;
  PVector velocity;
  PImage[] sprite;
  float mass;
  int charge;
  //float x, y, vx, vy;
  Particle (float x, float y, float vx, float vy){
    this.position=new PVector (x, y);
    this.velocity=new PVector (vx, vy);
    this.sprite=new PImage[1];
    this.sprite[0]=loadImage("default.gif");
  }
  void updatePosition(){
    position.add(velocity);
    //println("x: "+position.x+" y: "+position.y+" vx: "+velocity.x+" vy: "+velocity.y);
    if (abs(position.x)>width*5/8||abs(position.y)>height*5/8) {
      println("doom time! x="+position.x+", y="+position.y);
      particles.remove(this);
    }
  }
  
  void drawSprite(int frame){
    image(sprite[frame].get(), position.x, position.y, 33, 33);
  }
}
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

