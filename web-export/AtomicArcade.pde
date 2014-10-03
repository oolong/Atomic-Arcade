/* @pjs preload="circle-32.png, background-for-web-demo.jpg, proton-cannon-down.png, proton-cannon-neutral.png, proton-cannon-up.png, neutron-cannon-down.png, neutron-cannon-neutral.png, neutron-cannon-up.png, background-square.jpg, element-pad.png, circle-xxl.png, default.gif, default.png, neutron.gif, neutron0.png, neutron1.png, neutron2.png, neutron3.png, neutron4.png, neutron5.png, proton.gif, proton0.png, proton1.png, proton2.png, proton3.png, proton4.png, proton5.png"; 
 */

ArrayList<Nucleon> nucleons;
ArrayList<Bond> bonds;
ArrayList<Nucleon> doomed;
float doomTime=1666;
//ArrayList<Proton> protons;
float em=0.5; // Strength of the electromagnetic force
Proton protonOne;
float[] nuclearAttraction= { 
  0.25, 0.85, 0.005
}; // Neutron-neutron, proton-neutron, proton-proton nuclear force strength
float nuclearRepulsion=0.8;
float nucleonDiameter=30;
float damping=0.99;
int atomicNumber=0, neutrons=0;
int atomicMass=0;
int cannonCountdown=0, currentCannon=0;
static int SMILE=0, WHEEE=1, FROWN=2, CONCERN=3, OHNOEZ=4, BYEBYE=5;
static int NEUTRON=0, PROTON=1, POSITRON=2, ELECTRON=3, HELIUM=4, UNKNOWN=5; // Alpha decay is 'HELIUM' because ALPHA is a reserved word
float zoomLevel=1.5;
float[][] halfLives;
String[][] decayModes;
int[][] decayTypes;
String[] elementNames;
String[] elementSymbols;
int[] overallMood = { 
  0, 0
};
PImage backgroundImage, elementPad, protonCannonUp, neutronCannonUp, protonCannonNeutral, neutronCannonNeutral, protonCannonDown, neutronCannonDown, protonCannon, neutronCannon;
boolean debugging=false, java=false;

void setup () {
  size(512, 600);
  colorMode(RGB, 256);
  ellipseMode(CORNER);
  //orientation(LANDSCAPE);
  frameRate(30);
  nucleons=new ArrayList<Nucleon>();
  bonds=new ArrayList<Bond>();
  doomed=new ArrayList<Nucleon>();
  nucleons.add(new Proton(0, 0, 0, 0)); // Starting with a static hydrogen atom?
  protonOne=(Proton)nucleons.get(0);
  backgroundImage=loadImage("background-for-web-demo.jpg");
  elementPad=loadImage("element-pad.png");
  protonCannonNeutral=loadImage("proton-cannon-neutral.png");
  neutronCannonNeutral=loadImage("neutron-cannon-neutral.png");
  protonCannonDown=loadImage("proton-cannon-down.png");
  neutronCannonDown=loadImage("neutron-cannon-down.png");
  protonCannonUp=loadImage("proton-cannon-up.png");
  neutronCannonUp=loadImage("neutron-cannon-up.png");
  protonCannon=protonCannonNeutral;
  neutronCannon=neutronCannonNeutral;
  background (backgroundImage);
  elementNames=new String[119];
  elementSymbols=new String[119];
  elementNames[0]="Nothing?";
  elementSymbols[0]="0";
  loadData();
  //Java-only file loading routine. Bother.


  printIfDebugging("setup complete");
}

void draw () {
  /* Modelling bit will consist of:
   * looping over all plausible combinations of nucleons and applying nuclear force
   * looping over all of the protons and repelling them from each other
   * adjusting all velocities
   * adjusting all positions
   */

  background (backgroundImage);
  pushMatrix();
  translate(width/2, height/2);
  scale(zoomLevel);
  /* // Leave trails?
   fill (0, 8);
   rect (-width/2, -height/2, width, height);
   */

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
  //printIfDebugging("attractions complete");

  for (int i=0; i<nucleons.size (); i++) { // Position and mood updating  loop
    Nucleon thisNucleon=nucleons.get(i);
    thisNucleon.updatePosition();
    if (thisNucleon.moodTime>0) thisNucleon.moodTime--;
    else if (thisNucleon.linkedIn) { 
      //printIfDebugging("was "+thisNucleon.mood);
      thisNucleon.mood=overallMood[thisNucleon.charge];
    }
    else {
      thisNucleon.mood=OHNOEZ;  // UH OH, WHERE AM I GOING?! WHY IS EVERYONE FLOATING AWAY FROM ME?
    }
  }
  if (millis()>doomTime && doomed.size()>0) {  // Time's up
    for (int i=0; i<doomed.size(); i++) {
      doomed.get(i).mood=OHNOEZ; // It is not long for this world...
      //doomed.diameter=nucleonDiameter*5;
      //printIfDebugging("DOOM!");
      // doomed.get(i).decay(decayMode); // THE END IS NIGH
    }
  }
  if (millis()>doomTime +1000 && doomed.size()>0) {  // One second's grace period has elapsed.
    //printIfDebugging("Doom x="+doomed.get(0).position.x+" y="+doomed.get(0).position.y);
    //printIfDebugging("Doom velocity x="+doomed.get(0).velocity.x+" y="+doomed.get(0).velocity.y);
    /*PVector impulse=doomed.get(0).position.get();
     impulse.normalize();
     impulse.mult(10);*/
    //printIfDebugging("impulse x="+impulse.x+" y="+impulse.y);
    if (doomed.get(0)!=protonOne) {
      //doomed.get(0).diameter*=3;
      (doomed.get(0)).mood=BYEBYE;
      (doomed.get(0)).moodTime=1000;
      doomed.clear();
    }
  }
  //printIfDebugging("position-updating complete");
  int oldAtomicNumber=atomicNumber;
  int oldNeutrons=neutrons;
  atomicNumber=0;
  atomicMass=0;
  neutrons=0;
  for (int i=0; i<nucleons.size (); i++) { // Shadow-drawing loop
    nucleons.get(i).drawShadow();
  }
  for (int i=0; i<nucleons.size (); i++) { // Particle-drawing loop, also counts neutrons and mass
    nucleons.get(i).drawSprite();
    if (nucleons.get(i).linkedIn) {
      atomicMass++;
      nucleons.get(i).linkedIn=false;
      atomicNumber+=nucleons.get(i).charge;
      if (nucleons.get(i).charge==0) neutrons++;
    }
  }
  if (atomicNumber!=oldAtomicNumber||neutrons!=oldNeutrons) { // New nuclide time
    // Announce new element if (atomicNumber!=oldAtomicNumber)
    int newMood=SMILE;
    if (halfLives[atomicNumber][neutrons]<5) {
      newMood=CONCERN;
    }
    else if (halfLives[atomicNumber][neutrons]<15) {
      newMood=FROWN;
    }
    else { //
      overallMood[1]=SMILE;
      overallMood[0]=SMILE;
    }
    doomTime=(int)(millis()+1000*halfLives[atomicNumber][neutrons]*random(1)/random(1)); // Doom time is set within an infinite range centred on the half-life.
    printIfDebugging("Doom will be in "+(doomTime-millis())+" milliseconds");
    printIfDebugging("millis now="+millis());
    doomed.clear();
    if (decayTypes[atomicNumber][neutrons]==NEUTRON|decayTypes[atomicNumber][neutrons]==ELECTRON) {
      overallMood[0]=newMood;
      overallMood[1]=SMILE;
      doomed.add(chooseNucleon(0));
    }
    else if (decayTypes[atomicNumber][neutrons]==PROTON|decayTypes[atomicNumber][neutrons]==POSITRON) {
      overallMood[1]=newMood;
      overallMood[0]=SMILE;
      doomed.add(chooseNucleon(1));
    }
    else if (decayTypes[atomicNumber][neutrons]==HELIUM) {
      overallMood[1]=newMood;
      overallMood[0]=newMood;
      doomed.add(chooseNucleon(0));
      doomed.add(chooseNucleon(1));
      doomed.add(chooseNucleon(0));
      doomed.add(chooseNucleon(1));
    }
    else {         // If all else fails, smile
      overallMood[1]=SMILE;
      overallMood[0]=SMILE;
    }
  }
  protonOne.position.mult(0.9);
  protonOne.velocity.mult(0.9);
  protonOne.linkedIn=true;
  popMatrix();
  pushMatrix();
  translate(width-120, 0);
  scale(0.8);
  image(elementPad, 0, 25, 120, 120);
  fill(0);
  textAlign(LEFT);
  textSize(60);
  if (atomicNumber<elementSymbols.length) {
    text(elementSymbols[atomicNumber], 32, 100);
  }
  else {
    text("Xx", 0, 20);
  }
  textSize(16);
  textAlign(RIGHT);
  text(atomicNumber, 32, 72);
  text(atomicMass, 32, 100);
  textAlign(CENTER);
  textSize(18);
  if (elementNames[atomicNumber].length()>10) {
    textSize(14);
  }
  text(elementNames[atomicNumber], 60, 120);
  popMatrix();
  cannonCountdown--;
  if (cannonCountdown==4) {
    if (currentCannon==0) {
      protonCannon=protonCannonUp;
    }
    else {
      neutronCannon=neutronCannonUp;
    }
  }
  if (cannonCountdown==0) {
    protonCannon=protonCannonNeutral;
    neutronCannon=neutronCannonNeutral;
  }
  if (mousePressed==true) {
    if (mouseX<width/2) {
      protonCannon=protonCannonDown;
    }
    else {
      neutronCannon=neutronCannonDown;
    }
  }
  image(protonCannon, 0, height-120, 120, 120);
  image(neutronCannon, width-120, height-120, 120, 120);
  //printIfDebugging(decayModes[atomicNumber][neutrons]);
  //text("Decay mode: "+decayModes[atomicNumber][neutrons], 10, 50);
  //text("Halflife: "+halfLives[atomicNumber][neutrons], 10, 70);
}

Nucleon chooseNucleon(int charge) { // Choose the furthest matching nucleon from the centre, or the nearest to the latest already-doomed nucleon
  float greatestDistance=0;
  Nucleon currentNucleon;
  Nucleon furthestNucleon=protonOne;
  for (int i=0; i<nucleons.size(); i++) {
    currentNucleon=nucleons.get(i);
    if (currentNucleon.charge==charge) { // Find the furthest one
      float distance=sqrt(currentNucleon.position.x*currentNucleon.position.x + currentNucleon.position.y*currentNucleon.position.y);
      if (distance>greatestDistance) {
        greatestDistance=distance;
        furthestNucleon=currentNucleon;
      }
    }
  }
  return furthestNucleon;
}

void shootProton () {
  protonCannon=protonCannonNeutral;
  cannonCountdown=5;
  currentCannon=0;
  float relV=2*log((atomicNumber+9)/3);
  nucleons.add(new Proton (-width/(2*zoomLevel)+20, height/(2*zoomLevel)-50, relV, -relV*(height)/width));
}

void shootNeutron () {
  neutronCannon=neutronCannonNeutral;
  cannonCountdown=5;
  currentCannon=1;
  float relV=2*log((atomicNumber+9)/3);
  nucleons.add(new Neutron (width/(2*zoomLevel)-50, height/(2*zoomLevel)-50, -relV, -relV*(height)/width));
}


void keyPressed() {
  if (key=='p') {
    printIfDebugging("key p pressed");
    protonCannon=protonCannonDown;
  }
  if (key=='n') {
    printIfDebugging("key n pressed");
    neutronCannon=neutronCannonDown;
  }
}

void keyReleased() {
  printIfDebugging ("Atomic number="+atomicNumber+", atomic mass="+atomicMass);
  if (key=='p') {
    printIfDebugging("key p pressed");
    shootProton();
  }
  if (key=='n') {
    printIfDebugging("key n pressed");
    shootNeutron();
  }
  if (key=='r') {
    printIfDebugging("key r pressed");
    nucleons.clear();
    nucleons.add(new Proton(0, 0, 0, 0)); 
    protonOne=(Proton)nucleons.get(0);
  }
}


void mouseReleased() {
  if (mouseX<width/2) {
    shootProton();
  }
  else {
    shootNeutron();
  }
}


void printIfDebugging (String message) {
  if (debugging) println(message);
}

void loadData() {
  if (java) {
    Table nuclides=loadTable("halflives.tsv", "header");
    halfLives=new float[178][178];
    decayModes=new String[178][178];  
    decayTypes=new int[178][178];  
    for (int i=0; i<nuclides.getRowCount(); i++) {
      int protonCount=nuclides.getInt(i, 0);
      int neutronCount=nuclides.getInt(i, 1);
      float halfLife=0.1*log(nuclides.getFloat(i, 2)); // We're taking the natural logarithm of the real halflife to bring things into human timescales

      if (halfLife<0.1) halfLife=1;
      if (Float.isNaN(halfLife)) { 
        printIfDebugging("That's not a number!");
        halfLife=Float.MAX_VALUE;
      } 
      printIfDebugging("Z="+protonCount+", N="+neutronCount+", halfLife="+halfLife);
      halfLives[protonCount][neutronCount]=halfLife;
      String decayMode=nuclides.getString(i, 3);
      if (decayModes[protonCount][neutronCount]==null) decayModes[protonCount][neutronCount]=decayMode;
      if (decayMode.charAt(0)=='A') { 
        decayTypes[protonCount][neutronCount]=HELIUM;
      }
      else if (decayMode.charAt(0)=='E') { 
        decayTypes[protonCount][neutronCount]=POSITRON;
      }
      else if (decayMode.charAt(0)=='B') { 
        decayTypes[protonCount][neutronCount]=ELECTRON;
      }
      else if (decayMode.charAt(0)=='P') { 
        decayTypes[protonCount][neutronCount]=PROTON;
      }
      else if (decayMode.charAt(0)=='N') { 
        decayTypes[protonCount][neutronCount]=NEUTRON;
      }
      else { 
        decayTypes[protonCount][neutronCount]=UNKNOWN;
      }
      printIfDebugging("decayType="+decayTypes[protonCount][neutronCount]);
    }
    Table namesAndSymbols=loadTable("elementnames.csv");
    for (int i=0; i<namesAndSymbols.getRowCount(); i++) {
      int protonCount=namesAndSymbols.getInt(i, 0);
      String name=namesAndSymbols.getString(i, 2);
      String symbol=namesAndSymbols.getString(i, 3);
      printIfDebugging("Atomic Number="+protonCount+", name="+name+", symbol="+symbol);
      elementNames[protonCount]=name;
      elementSymbols[protonCount]=symbol;
      //halfLives[protonCount][neutronCount]=halfLife;
    }    // End Java-only bit
  }
  else {
    // JavaScript-only routine for reading and parsing files 
    String[] namesAndSymbols=loadStrings("elementnames.tsv");
    printIfDebugging(namesAndSymbols[0]);
    for (int i=0; i<namesAndSymbols.length; i++) {
      String[] thisLine=splitTokens(namesAndSymbols[i]);
      printIfDebugging(thisLine[0]+ ", "+thisLine[1]+", "+thisLine[2]+", "+thisLine[3]);
      elementNames[i+1]=thisLine[2];
      elementSymbols[i+1]=thisLine[3];
    }
    String[] nuclides=loadStrings("halflives.tsv");
    halfLives=new float[178][178];
    decayModes=new String[178][178];  
    decayTypes=new int[178][178];  
    for (int i=1; i<nuclides.length; i++) {
      String[] thisLine=splitTokens(nuclides[i]);
      int protonCount=thisLine[0];
      int neutronCount=thisLine[1];
      float halfLife=thisLine[2];
      if (isNaN(parseFloat(halfLife))|halfLife==0) { 
        halfLife=100000000000;
      } 
      printIfDebugging("Z="+protonCount+", N="+neutronCount+", halfLife="+halfLife);
      halfLives[protonCount][neutronCount]=halfLife;
      String decayMode=thisLine[3];
      decayModes[protonCount][neutronCount]=decayMode;
      printIfDebugging ("decayMode "+decayMode);
      if (decayMode.charAt(0)=='A') { 
        decayTypes[protonCount][neutronCount]=HELIUM;
      }
      else if (decayMode.charAt(0)=='E') { 
        decayTypes[protonCount][neutronCount]=POSITRON;
      }
      else if (decayMode.charAt(0)=='B') { 
        decayTypes[protonCount][neutronCount]=ELECTRON;
      }
      else if (decayMode.charAt(0)=='P') { 
        decayTypes[protonCount][neutronCount]=PROTON;
      }
      else if (decayMode.charAt(0)=='N') { 
        decayTypes[protonCount][neutronCount]=NEUTRON;
      }
      else { 
        decayTypes[protonCount][neutronCount]=UNKNOWN;
      }
      printIfDebugging("decayType="+decayTypes[protonCount][neutronCount]);
    }   // End JS-only bit
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
    this.sprite=new PImage[6];
    for (int i=0; i<6; i++){
      this.sprite[i]=loadImage("neutron"+i+".png");
    }
    this.charge=0;
    printIfDebugging("Neutron mood on creation: "+this.mood+" moodTime: "+moodTime);
  }
}  
class Nucleon extends Particle { // It's possible this should be an interface
  boolean fixed=false;
  int mood, moodTime;
  float diameter;
  Nucleon (float x, float y, float vx, float vy) {
    super (x, y, vx, vy);
    mood=WHEEE;
    moodTime=200;
    diameter=nucleonDiameter;
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
      printIfDebugging("BYEBYE FORCE");
    }
    if (this.mood==OHNOEZ | that.mood==OHNOEZ){
      attractionMultiplier*=0.6;
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
        if (magnitude>0.5 && attractionMultiplier==-1) { // Express slight concern about bouncing
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
      else {
        PVector collisionPoint=new PVector((this.position.x+that.position.x)/2, (this.position.y+that.position.y)/2);
        PVector thisVector=PVector.sub(this.position, collisionPoint);
        float thisDistance=thisVector.mag();
        this.position.add(PVector.mult(thisVector, (this.diameter-thisDistance)/(2*this.diameter)));
        that.position.sub(PVector.mult(thisVector, (this.diameter-thisDistance)/(2*this.diameter)));
      }
    }
  }
  void drawSprite() {
    image(sprite[mood].get(), position.x, position.y, 30, 30);
  }
  void drawShadow() {
    noStroke();
    fill(0, 64);
    ellipse(position.x-5, position.y+5, 27, 27);
  }
}

class Particle {
  PVector position;
  PVector velocity;
  PImage[] sprite;
  float mass;
  int charge;
  boolean linkedIn=false;
  //float x, y, vx, vy;
  Particle (float x, float y, float vx, float vy){
    this.position=new PVector (x, y);
    this.velocity=new PVector (vx, vy);
    this.sprite=new PImage[1];
    this.sprite[0]=loadImage("default.gif");
  }
  void updatePosition(){
    position.add(velocity);
    //float distFromCentre=mag(this.position.x,this.position.y);
    if (linkedIn) {
      position.add(new PVector(-position.y/500, position.x/500));
      velocity.mult(damping); // It may make more sense to apply damping once per linked particle elsewhere
    }
       
    //printIfDebugging("x: "+position.x+" y: "+position.y+" vx: "+velocity.x+" vy: "+velocity.y);
    if (abs(position.x)>width*5/8||abs(position.y)>height*5/8) {
      printIfDebugging("doom time! x="+position.x+", y="+position.y);
      nucleons.remove(this);
    }
  }
  
  void drawSprite(){
    image(sprite[0].get(), position.x, position.y, 30, 30);
  }
}
class Proton extends Nucleon {
  Proton (float x, float y, float vx, float vy){
    super (x, y, vx, vy);
    this.sprite=new PImage[6];
    for (int i=0; i<6; i++){
      this.sprite[i]=loadImage("proton"+i+".png");
    }
    this.charge=1;
    printIfDebugging("Proton mood on creation: "+this.mood);
  }
  void repel (Proton that){
    // calculate distance and angle, alter velocities
    PVector difference=PVector.sub (this.position, that.position);
    float distSq=sq(difference.x)+sq(difference.y); // Use Pythagoras to get the square of the distance between the vectors
    float magnitude=em/distSq;
    PVector force=(PVector.sub (this.position, that.position));//.heading();
    force.normalize();
    force.mult (magnitude);
    //printIfDebugging ("repelling by "+magnitude);
    if (this.fixed!=true) {
      this.velocity.add(force);
    }
    if (that.fixed!=true) {
      that.velocity.sub (force);
    }    
  }  
}

