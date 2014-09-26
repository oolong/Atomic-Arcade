/* @pjs preload="circle-32.png, circle-xxl.png, default.gif, default.png, neutron.gif, neutron1.png, neutron2.png, neutron3.png, neutron4.png, proton.gif, proton0.png, proton1.png, proton2.png, proton3.png, proton4.png"; 
 */

ArrayList<Nucleon> nucleons;
ArrayList<Bond> bonds;
//ArrayList<Proton> protons;
float em=0.5; // Strength of the electromagnetic force
Proton ProtonOne;
float[] nuclearAttraction={ 
  0.25, 0.85, 0.005
}; // Neutron-neutron, proton-neutron, proton-proton nuclear force strength
float nuclearRepulsion=0.8;
float nucleonDiameter=30;
float damping=0.99;
int atomicNumber=0;
int atomicMass=0;
static int SMILE=0, WHEEE=1, FROWN=2, CONCERN=3, OHNOEZ=4;
static int NEUTRON=0, PROTON=1, POSITRON=2, ELECTRON=3, HELIUM=4, UNKNOWN=5; // Alpha decay is 'HELIUM' because ALPHA is a reserved word
float zoomLevel=1.5;
float[][] halfLives;
String[][] decayModes;
int[][] decayTypes;
String[] elementNames;
String[] elementSymbols;
int[] overallMood = { 0, 0 };

void setup () {
  size(800, 600);
  //orientation(LANDSCAPE);
  frameRate(30);
  nucleons=new ArrayList<Nucleon>();
  bonds=new ArrayList<Bond>();
  nucleons.add(new Proton(0, 0, 0, 0)); // Starting with a static hydrogen atom?
  ProtonOne=(Proton)nucleons.get(0);
  background (0);
  elementNames=new String[119];
  elementSymbols=new String[119];
  elementNames[0]="Nothing?";
  elementSymbols[0]="0";

 //Java-only file loading routine. Bother.
Table nuclides=loadTable("halflives.tsv", "header");
  halfLives=new float[178][178];
  decayModes=new String[178][178];  
  decayTypes=new int[178][178];  
  for (int i=0; i<nuclides.getRowCount(); i++){
    int protonCount=nuclides.getInt(i, 0);
    int neutronCount=nuclides.getInt(i, 1);
    float halfLife=nuclides.getFloat(i, 2);
    if (Float.isNaN(halfLife)){ 
      println("That's not a number!");
      halfLife=Float.MAX_VALUE;
    } 
    println("Z="+protonCount+", N="+neutronCount+", halfLife="+halfLife);
    halfLives[protonCount][neutronCount]=halfLife;
    String decayMode=nuclides.getString(i,3);
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
    println("decayType="+decayTypes[protonCount][neutronCount]);

  }
  Table namesAndSymbols=loadTable("elementnames.csv");
  for (int i=0; i<namesAndSymbols.getRowCount(); i++){
    int protonCount=namesAndSymbols.getInt(i, 0);
    String name=namesAndSymbols.getString(i, 2);
    String symbol=namesAndSymbols.getString(i, 3);
    println("Atomic Number="+protonCount+", name="+name+", symbol="+symbol);
    elementNames[protonCount]=name;
    elementSymbols[protonCount]=symbol;
    //halfLives[protonCount][neutronCount]=halfLife;
  }  // End Java-only bit
   /*// JavaScript-only routine for reading and parsing files 
  String[] namesAndSymbols=loadStrings("elementnames.tsv");
  println(namesAndSymbols[0]);
  for (int i=0; i<namesAndSymbols.length; i++){
    String[] thisLine=splitTokens(namesAndSymbols[i]);
    println(thisLine[0]+ ", "+thisLine[1]+", "+thisLine[2]+", "+thisLine[3]);
    elementNames[i+1]=thisLine[2];
    elementSymbols[i+1]=thisLine[3];
  }
  String[] nuclides=loadStrings("halflives.tsv");
  halfLives=new float[178][178];
  decayModes=new String[178][178];  
  for (int i=1; i<nuclides.length; i++){
    String[] thisLine=splitTokens(nuclides[i]);
    int protonCount=thisLine[0];
    int neutronCount=thisLine[1];
    float halfLife=thisLine[2];
    if (isNaN(parseFloat(halfLife))){ 
      halfLife=100000000000;
    } 
    println("Z="+protonCount+", N="+neutronCount+", halfLife="+halfLife);
    halfLives[protonCount][neutronCount]=halfLife;
    String decayMode=thisLine[3];
    decayModes[protonCount][neutronCount]=decayMode;
  } */// End JS-only bit
  
  println("setup complete");
}

void draw () {
  /* Modelling bit will consist of:
   * looping over all plausible combinations of nucleons and applying nuclear force
   * looping over all of the protons and repelling them from each other
   * adjusting all velocities
   * adjusting all positions
   */

  background (0);
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
  //println("attractions complete");

  for (int i=0; i<nucleons.size (); i++) { // Position-updating loop
    Nucleon thisNucleon=nucleons.get(i);
    thisNucleon.updatePosition();
    if (thisNucleon.moodTime>0) thisNucleon.moodTime--;
    else if (thisNucleon.linkedIn) {
      //println("was "+thisNucleon.mood);
      thisNucleon.mood=overallMood[thisNucleon.charge];
    }
    else {
      thisNucleon.mood=OHNOEZ;
    }
  }
  //println("position-updating complete");
  int oldAtomicNumber=atomicNumber;
  int oldNeutrons=neutrons;
  atomicNumber=0;
  atomicMass=0;
  int neutrons=0;
  for (int i=0; i<nucleons.size (); i++) { // Particle-drawing loop
    nucleons.get(i).drawSprite();
    if (nucleons.get(i).linkedIn) {
      atomicMass++;
      nucleons.get(i).linkedIn=false;
      atomicNumber+=nucleons.get(i).charge;
      if (nucleons.get(i).charge==0) neutrons++;
    }
  }
  if (atomicNumber!=oldAtomicNumber||neutrons!=oldNeutrons){
    // Announce new element
    int newMood=SMILE;
    if (halfLives[atomicNumber][neutrons]<100000) newMood=FROWN;
    else if (halfLives[atomicNumber][neutrons]<1000) newMood=CONCERN;
    else {
      overallMood[1]=SMILE;
      overallMood[0]=SMILE;
    }     
    if (decayTypes[atomicNumber][neutrons]==NEUTRON|decayTypes[atomicNumber][neutrons]==ELECTRON){
      overallMood[0]=newMood;
      overallMood[1]=SMILE;
    }
    else if (decayTypes[atomicNumber][neutrons]==PROTON|decayTypes[atomicNumber][neutrons]==POSITRON){
      overallMood[1]=newMood;
      overallMood[0]=SMILE;
    }
    else if (decayTypes[atomicNumber][neutrons]==HELIUM) {
      overallMood[1]=newMood;
      overallMood[0]=newMood;
    }
    else {
      overallMood[1]=SMILE;
      overallMood[0]=SMILE;
    }     
      
  }
  ProtonOne.position.mult(0.9);
  ProtonOne.velocity.mult(0.9);
  ProtonOne.linkedIn=true;
  popMatrix();
  pushMatrix();
  translate(width/2,0);
  scale(4);
  textAlign(LEFT);
  if (atomicNumber<elementSymbols.length){
    text(elementSymbols[atomicNumber],0,20);
  }
  else {
    text("Xx",0,20);
  }
  scale(0.4);
  textAlign(RIGHT);
  text(atomicNumber,0,35);
  text(atomicMass,0,50);
  popMatrix();
  textAlign(LEFT);
  text(elementNames[atomicNumber],10,30);
  //println(decayModes[atomicNumber][neutrons]);
  text("Decay mode: "+decayModes[atomicNumber][neutrons],10,50);
  text("Halflife: "+halfLives[atomicNumber][neutrons],10,70);
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
