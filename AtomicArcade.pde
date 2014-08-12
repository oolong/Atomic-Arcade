/* @pjs preload="circle-32.png, circle-xxl.png, default.gif, default.png, neutron.gif, neutron1.png, neutron2.png, neutron3.png, neutron4.png, proton.gif, proton0.png, proton1.png, proton2.png, proton3.png, proton4.png"; 
 */

ArrayList<Nucleon> nucleons;
ArrayList<Bond> bonds;
//ArrayList<Proton> protons;
float em=0.5; // Strength of the electromagnetic force
Proton ProtonOne;
float[] nuclearAttraction={ 
  0.35, 0.9, 0.005
}; // Neutron-neutron, proton-neutron, proton-proton nuclear force strength
float nuclearRepulsion=0.8;
float nucleonDiameter=30;
float damping=0.99;
int atomicNumber=0;
int atomicMass=0;
int SMILE=0, WHEEE=1, FROWN=2, CONCERN=3, OHNOEZ=4;
float zoomLevel=1;

void setup () {
  size(800, 600);
  frameRate(30);
  nucleons=new ArrayList<Nucleon>();
  bonds=new ArrayList<Bond>();
  nucleons.add(new Proton(0, 0, 0, 0)); // Starting with a static hydrogen atom?
  /*  nucleons.add(new Neutron(-40,0,0,-0.2)); // Starting with a static hydrogen atom?
   nucleons.add(new Proton(0,30,0,0)); // Starting with a static hydrogen atom?
   nucleons.add(new Neutron(40,0,0,0)); // Starting with a static hydrogen atom?
   nucleons.add(new Proton(50,-40,0,0)); // Starting with a static hydrogen atom?
   nucleons.add(new Neutron(90,50,0,0)); // Starting with a static hydrogen atom?
   */  // We'll also need to create the UI here, of course
  /*bonds.add(new Bond((Nucleon)nucleons.get(0),(Nucleon)nucleons.get(1)));
   bonds.add(new Bond((Nucleon)nucleons.get(1),(Nucleon)nucleons.get(2)));
   bonds.add(new Bond((Nucleon)nucleons.get(2),(Nucleon)nucleons.get(3)));
   bonds.add(new Bond((Nucleon)nucleons.get(3),(Nucleon)nucleons.get(0)));
   bonds.add(new Bond((Nucleon)nucleons.get(3),(Nucleon)nucleons.get(1)));
   bonds.add(new Bond((Nucleon)nucleons.get(0),(Nucleon)nucleons.get(2)));
   //nucleons.get(0).fixed=true;
   */
  background (0);
  println("setup complete");
  ProtonOne=(Proton)nucleons.get(0);
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

  background (0);
  translate(width/2, height/2);
  scale(zoomLevel);
  /*fill (0, 8);
  rect (-width/2, -height/2, width, height);
*/
  //println("first loop through complete");

  for (int i=0; i<nucleons.size ()-1; i++) { // Loop through all possible pairs of nucleons, repel protons, apply nuclear force
    Nucleon particle1=nucleons.get(i);
    for (int j=i+1; j<nucleons.size (); j++) {
      Nucleon particle2=nucleons.get(j);
      //checkBonds (particle1, particle2);
      if (particle1.charge * particle2.charge==1) { // Only happens if both particles are protons
        ((Proton)particle1).repel((Proton)particle2);
      }
      particle1.attract(particle2);
    }
  }

  /*for (int i=0; i<bonds.size(); i++){ // Bond-attraction loop
   bonds.get(i).attract();
   }*/
  //println("attractions complete");

  for (int i=0; i<nucleons.size (); i++) { // Position-updating loop
    thisNucleon=nucleons.get(i);
    thisNucleon.updatePosition();
    if (thisNucleon.moodTime>0) thisNucleon.moodTime--;
    else {
      //println("was "+thisNucleon.mood);
      thisNucleon.mood=0;
    }
  }
  //println("position-updating complete");
  atomicNumber=0;
  atomicMass=0;
  for (int i=0; i<nucleons.size (); i++) { // Particle-drawing loop
    nucleons.get(i).drawSprite();
    if (nucleons.get(i).linkedIn) {
      atomicMass++;
      nucleons.get(i).linkedIn=false;
      atomicNumber+=nucleons.get(i).charge;
    }
  }
  ProtonOne.position.mult(0.9);
  ProtonOne.velocity.mult(0.9);
  ProtonOne.linkedIn=true;
}

void shootProton () {
  float relV=2*log((atomicNumber+9)/3);
  nucleons.add(new Proton (-width/(2*zoomLevel), height/(2*zoomLevel), relV, -relV*(height)/width));
}

void shootNeutron () {
  float relV=2*log((atomicNumber+9)/3);
  nucleons.add(new Neutron (width/(2*zoomLevel), height/(2*zoomLevel), -relV, -relV*(height)/width));
}

void keyPressed() {
  println ("Atomic number="+atomicNumber+", atomic mass="+atomicMass);
  if (key=='p') {
    println("key p pressed");
    shootProton();
  }
  if (key=='n') {
    println("key n pressed");
    shootNeutron();
  }
  if (key=='r') {
    println("key r pressed");
    nucleons.clear();
    nucleons.add(new Proton(0, 0, 0, 0)); 
    ProtonOne=(Proton)nucleons.get(0);
  }
  
}

void mousePressed() {
  if (mouseX<width/2) {
    shootProton();
  }
  else {
    shootNeutron();
  }
}
