/* @pjs preload="circle-32.png, proton-cannon-down.png, proton-cannon-neutral.png, proton-cannon-up.png, neutron-cannon-down.png, neutron-cannon-neutral.png, neutron-cannon-up.png, background-square.jpg, element-pad.png, circle-xxl.png, default.gif, default.png, neutron.gif, neutron0.png, neutron1.png, neutron2.png, neutron3.png, neutron4.png, proton.gif, proton0.png, proton1.png, proton2.png, proton3.png, proton4.png"; 
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
static int SMILE=0, WHEEE=1, FROWN=2, CONCERN=3, OHNOEZ=4;
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
PImage backgroundImage, elementPad, protonCannon, neutronCannon;
boolean debugging=true, java=false;

void setup () {
  size(992, 850);
  colorMode(RGB, 256);
  ellipseMode(CORNER);
  //orientation(LANDSCAPE);
  frameRate(30);
  nucleons=new ArrayList<Nucleon>();
  bonds=new ArrayList<Bond>();
  doomed=new ArrayList<Nucleon>();
  nucleons.add(new Proton(0, 0, 0, 0)); // Starting with a static hydrogen atom?
  protonOne=(Proton)nucleons.get(0);
  backgroundImage=loadImage("background-square.jpg");
  elementPad=loadImage("element-pad.png");
  protonCannon=loadImage("proton-cannon-neutral.png");
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
      thisNucleon.mood=OHNOEZ;
    }
  }
  if (millis()>doomTime && doomed.size()>0) {  // Time's up
    for (int i=0; i<doomed.size(); i++) {
      doomed.get(i).mood=OHNOEZ;
      //doomed.diameter=nucleonDiameter*5;
      //printIfDebugging("DOOM!");
      // doomed.get(i).decay(decayMode); // THE END IS NIGH
    }
  }
  if (millis()>doomTime +1000 && doomed.size()>0) {  // Time's up
    //printIfDebugging("Doom x="+doomed.get(0).position.x+" y="+doomed.get(0).position.y);
    //printIfDebugging("Doom velocity x="+doomed.get(0).velocity.x+" y="+doomed.get(0).velocity.y);
    PVector impulse=doomed.get(0).position.get();
    impulse.normalize();
    impulse.mult(10);
    //printIfDebugging("impulse x="+impulse.x+" y="+impulse.y);
    if (doomed.get(0)!=protonOne) {
      //doomed.get(0).diameter*=3;
      doomed.get(0).velocity.add(impulse);
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
  translate(width-220, 0);
  image(elementPad, 0, 25, 200, 200);
  scale(7);
  fill(0);
  textAlign(LEFT);
  if (atomicNumber<elementSymbols.length) {
    text(elementSymbols[atomicNumber], 10, 20);
  }
  else {
    text("Xx", 0, 20);
  }
  scale(0.4);
  textAlign(RIGHT);
  text(atomicNumber, 22, 35);
  text(atomicMass, 22, 52);
  textAlign(CENTER);
  textSize(10);
  if(elementNames[atomicNumber].length()>10) {
    textSize(8);
  }
  text(elementNames[atomicNumber], 36, 64);
  popMatrix();
  image(protonCannon, 0, height-150, 150, 150);
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
  float relV=2*log((atomicNumber+9)/3);
  nucleons.add(new Proton (-width/(2*zoomLevel), height/(2*zoomLevel), relV, -relV*(height)/width));
}

void shootNeutron () {
  float relV=2*log((atomicNumber+9)/3);
  nucleons.add(new Neutron (width/(2*zoomLevel), height/(2*zoomLevel), -relV, -relV*(height)/width));
}


void keyPressed() {

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

void mousePressed() {
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

