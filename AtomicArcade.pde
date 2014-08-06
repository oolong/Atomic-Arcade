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

