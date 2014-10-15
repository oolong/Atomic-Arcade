/* @pjs preload="circle-32.png, helpPageWeb.jpg, background-for-web-demo.jpg, proton-cannon-down.png, proton-cannon-neutral.png, proton-cannon-up.png, neutron-cannon-down.png, neutron-cannon-neutral.png, neutron-cannon-up.png, background-square.jpg, element-pad.png, circle-xxl.png, default.gif, default.png, neutron.gif, neutron0.png, neutron1.png, neutron2.png, neutron3.png, neutron4.png, neutron5.png, proton.gif, proton0.png, proton1.png, proton2.png, proton3.png, proton4.png, proton5.png"; 
 */

Nucleon[] nucleons;
Nucleon[] doomed;
float doomTime=1666;
float em=0.5; // Strength of the electromagnetic force
Proton protonOne;
float[] nuclearAttraction= { 
  0.25, 0.85, 0.005
}; // Neutron-neutron, proton-neutron, proton-proton nuclear force strength
float nuclearRepulsion=0.8;
float nucleonDiameter=30;
float damping=0.99;
int atomicNumber=0, neutrons=0, killList=0;
int atomicMass=0, nucleonCount=0, particlesMade=0;
int neutronCannonCountdown=0, protonCannonCountdown=0, currentCannon=0;
final int SMILE=0, WHEEE=1, FROWN=2, CONCERN=3, OHNOEZ=4, BYEBYE=5;
final int NEUTRON=0, PROTON=1, POSITRON=2, ELECTRON=3, HELIUM=4, UNKNOWN=5; // Alpha decay is 'HELIUM' because ALPHA is a reserved word
float zoomLevel=1.25;
float[][] halfLives;
String[][] decayModes;
int[][] decayTypes;
String[] elementNames;
String[] elementSymbols;
int[] overallMood = { 
  0, 0
};
PImage backgroundImage, helpScreen, elementPad, protonCannonUp, neutronCannonUp, protonCannonNeutral, neutronCannonNeutral, protonCannonDown, neutronCannonDown, protonCannon, neutronCannon;
PImage[] protonImages, neutronImages;
boolean debugging=true, java=false, paused=false;

void setup () {
  size(512, 600);
  colorMode(RGB, 256);
  ellipseMode(CORNER);
  //orientation(LANDSCAPE);
  frameRate(30);
  helpScreen=loadImage("helpPageWeb.jpg");
  background (helpScreen);
  noLoop();
  nucleons=new Nucleon[300];
  doomed=new Nucleon[16];
  backgroundImage=loadImage("background-for-web-demo.jpg");
  elementPad=loadImage("element-pad.png");
  protonImages=new PImage[7];
  neutronImages=new PImage[7];
  for (int i=0; i<6; i++) {
    neutronImages[i]=loadImage("neutron"+i+".png");
    protonImages[i]=loadImage("proton"+i+".png");
  }  
  protonCannonNeutral=loadImage("proton-cannon-neutral.png");
  neutronCannonNeutral=loadImage("neutron-cannon-neutral.png");
  protonCannonDown=loadImage("proton-cannon-down.png");
  neutronCannonDown=loadImage("neutron-cannon-down.png");
  protonCannonUp=loadImage("proton-cannon-up.png");
  neutronCannonUp=loadImage("neutron-cannon-up.png");
  protonCannon=protonCannonNeutral;
  neutronCannon=neutronCannonNeutral;
  elementNames=new String[119];
  elementSymbols=new String[119];
  elementNames[0]="Nothing?";
  elementSymbols[0]="0";
  protonOne=new Proton(0, 0, 0, 0);
  loadData(); // Note that this method needs commenting or uncommenting depending on mode
  printIfDebugging("setup complete - nucleonCount="+nucleonCount);
  //redraw();
}

void draw () {
  /* Modelling bit will consist of:
   * looping over all plausible combinations of nucleons and applying nuclear force
   * looping over all of the protons and repelling them from each other
   * adjusting all velocities
   * adjusting all positions
   */

  if (paused) {
    background(helpScreen);
    image(helpScreen, 0, 0);
    //printIfDebugging("Paused why is it paused wth");
  }
  else {
    //printIfDebugging("Not paused");
    background (backgroundImage);
    pushMatrix();
    translate(width/2, height/2);
    if (atomicMass>39 && atomicMass<119 && zoomLevel>1) {
      zoomLevel*=0.98;
    }
    else if (atomicMass>119 && zoomLevel>0.75) {
      zoomLevel*=0.98;
    }
    scale(zoomLevel);
    /* // Leave trails?
     fill (0, 8);
     rect (-width/2, -height/2, width, height);
     */

    for (int i=0; i<nucleonCount; i++) { // Loop through all possible pairs of nucleons, repel protons, apply nuclear force
      Nucleon particle1=nucleons[i];
      if (particle1.active) {
        for (int j=i+1; j<nucleonCount; j++) {
          Nucleon particle2=nucleons[j];
          if (particle2.active) {
            if (particle1.charge * particle2.charge==1) { // Only happens if both particles are protons
              ((Proton)particle1).repel((Proton)particle2);
            }
            particle1.attract(particle2);
          }
        }
      }
    }

    // Point at which IDE fucked right up


    for (int i=0; i<nucleonCount; i++) { // Position and mood updating  loop
      if (nucleons[i].active) {
        Nucleon thisNucleon=nucleons[i];
        thisNucleon.updatePosition();
        if (millis()>doomTime+2000 && thisNucleon.mood==OHNOEZ) {
          thisNucleon.mood=BYEBYE;
          thisNucleon.moodTime=2000;
        }
        if (millis()<doomTime+1000 && thisNucleon.mood==BYEBYE) {
          thisNucleon.mood=WHEEE;
          thisNucleon.moodTime=500;
        }
        if (thisNucleon.moodTime>0) thisNucleon.moodTime--;
        else if (thisNucleon.linkedIn) { 
          //printIfDebugging("was "+thisNucleon.mood);
          thisNucleon.mood=overallMood[thisNucleon.charge];
        }
        else {
          thisNucleon.mood=OHNOEZ;  // UH OH, WHERE AM I GOING?! WHY IS EVERYONE FLOATING AWAY FROM ME?
        }
      }
    }
    if (millis()>doomTime && killList>0) {  // Time to doom this thing
      printIfDebugging("Doom scheduled! killList="+killList);
      for (int i=0; i<killList; i++) {
        doomed[i].mood=OHNOEZ; 
        doomed[i].moodTime=2500; // It is not long for this world...
        //doomed.diameter=nucleonDiameter*5;
        //printIfDebugging("DOOM!");
        // doomed.get(i).decay(decayMode); // THE END IS NIGH
      }
      killList=0;
    }/*
    if (millis()>doomTime + 2000 && killList>0) {  // Two second's grace period has elapsed.
     //printIfDebugging("Doom x="+doomed.get(0).position.x+" y="+doomed.get(0).position.y);
     //printIfDebugging("Doom velocity x="+doomed.get(0).velocity.x+" y="+doomed.get(0).velocity.y);
     //PVector impulse=doomed.get(0).position.get();
     // impulse.normalize();
     // impulse.mult(10);
     //printIfDebugging("impulse x="+impulse.x+" y="+impulse.y);
     if (doomed[0]!=protonOne && killList>0) {
     //doomed.get(0).diameter*=3;
     (doomed[0]).mood=BYEBYE;
     (doomed[0]).moodTime=2000;
     doomed[0]=null;
     killList=0;
     }
     }*/
    //printIfDebugging("position-updating complete");
    int oldAtomicNumber=atomicNumber;
    int oldNeutrons=neutrons;
    atomicNumber=0;
    atomicMass=0;
    neutrons=0;
    for (int i=0; i<nucleonCount; i++) { // Shadow-drawing loop
      if (nucleons[i].active) {
        nucleons[i].drawShadow();
      }
    }
    for (int i=0; i<nucleonCount; i++) { // Particle-drawing loop, also counts neutrons and mass
      if (nucleons[i].active) {
        nucleons[i].drawSprite();
        if (nucleons[i].linkedIn) {
          atomicMass++;
          nucleons[i].linkedIn=false;
          atomicNumber+=nucleons[i].charge;
          if (nucleons[i].charge==0) neutrons++;
        }
      }
    }
    if (atomicNumber!=oldAtomicNumber||neutrons!=oldNeutrons) { // New nuclide time
      // Announce new element if (atomicNumber!=oldAtomicNumber)
      // Here we establish how happy the protons and neutrons should be, and if one of them needs to decay
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
      killList=0;
      if (decayTypes[atomicNumber][neutrons]==NEUTRON|decayTypes[atomicNumber][neutrons]==ELECTRON) {
        overallMood[0]=newMood;
        overallMood[1]=SMILE;
        doomed[0]=chooseNucleon(0);
        killList=1;
      }
      else if (decayTypes[atomicNumber][neutrons]==PROTON|decayTypes[atomicNumber][neutrons]==POSITRON) {
        overallMood[1]=newMood;
        overallMood[0]=SMILE;
        doomed[0]=chooseNucleon(1);
        killList=1;
      }
      else if (decayTypes[atomicNumber][neutrons]==HELIUM) {
        overallMood[1]=newMood;
        overallMood[0]=newMood;
        doomed[0]=chooseNucleon(0);
        doomed[1]=chooseNucleon(1);
        doomed[2]=chooseNucleon(0);
        doomed[3]=chooseNucleon(1);
        killList=4;
      }
      else {         // If all else fails, smile
        overallMood[1]=SMILE;
        overallMood[0]=SMILE;
        killList=0;
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
      text(elementSymbols[atomicNumber], 32, 96);
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
    text(elementNames[atomicNumber], 60, 122);
    popMatrix();
    protonCannonCountdown--;
    neutronCannonCountdown--;
    if (protonCannonCountdown==4) {
      protonCannon=protonCannonUp;
    }
    if (neutronCannonCountdown==4) {
      neutronCannon=neutronCannonUp;
    }
    if (protonCannonCountdown==0) {
      protonCannon=protonCannonNeutral;
    }
    if (neutronCannonCountdown==0) {
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
}
Nucleon chooseNucleon(int charge) { // Choose the furthest matching nucleon from the centre, or the nearest to the latest already-doomed nucleon
  float greatestDistance=0;
  Nucleon currentNucleon;
  Nucleon furthestNucleon=protonOne;
  for (int i=0; i<nucleonCount; i++) {
    currentNucleon=nucleons[i];
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
  if (protonCannonCountdown<1) {
    protonCannon=protonCannonNeutral;
    protonCannonCountdown=8;
    currentCannon=0;
    //float relV=2*log((atomicNumber+9)/3);
    float relV=3;
    new Proton (-width/(2*zoomLevel)+25, height/(2*zoomLevel)-54, relV, -relV*(height)/width);
  }
}

void shootNeutron () {
  if (neutronCannonCountdown<1) {
    printIfDebugging("shootNeutron called");
    neutronCannon=neutronCannonNeutral;
    neutronCannonCountdown=8;
    currentCannon=1;
    //float relV=2*log((atomicNumber+9)/3);
    float relV=3;
    new Neutron (width/(2*zoomLevel)-44, height/(2*zoomLevel)-54, -relV, -relV*(height)/width);
    printIfDebugging("Neutron may have been created?");
  }
}


void keyPressed() {
  paused=false;
  loop();
  if (key=='p') {
    // printIfDebugging("key p pressed");
    protonCannon=protonCannonDown;
  }
  if (key=='n') {
    // printIfDebugging("key n pressed");
    neutronCannon=neutronCannonDown;
  }
  if (key=='h') {
    paused=true;
    background(helpScreen);
    noLoop();
    redraw();
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
    for (int i=0; i<nucleonCount; i++) {
      nucleons[i].active=false;
    }
    protonOne=new Proton(0, 0, 0, 0);
  }
}


void mouseReleased() {
  paused=false;
  loop();
  printIfDebugging("paused="+paused);
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
    } // End JS-only bit
  }
}

