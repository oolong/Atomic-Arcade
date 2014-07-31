
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
  
