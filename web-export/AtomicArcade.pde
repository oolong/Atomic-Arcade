/* @pjs preload="circle-32.png, start-page.jpg, pause-page.jpg, background-for-web-demo.jpg, proton-cannon-down.png, proton-cannon-neutral.png, proton-cannon-up.png, neutron-cannon-down.png, neutron-cannon-neutral.png, neutron-cannon-up.png, background-square.jpg, element-pad.png, circle-xxl.png, default.gif, default.png, neutron.gif, neutron0.png, neutron1.png, neutron2.png, neutron3.png, neutron4.png, neutron5.png, proton.gif, proton0.png, proton1.png, proton2.png, proton3.png, proton4.png, proton5.png"; 
 */

Nucleon[] nucleons;
Nucleon[] doomed;
String[] halfLifeList; // To store half-life information.
float doomTime=1666;
float em=0.5; // Strength of the electromagnetic force
Proton protonOne;
float[] nuclearAttraction= { 
  0.25, 0.85, 0.005
}; // Neutron-neutron, proton-neutron, proton-proton nuclear force strength
float nuclearRepulsion=0.8;
float nucleonDiameter=30;
float damping=0.99, vibrate=2;
int atomicNumber=0, neutrons=0, killList=0;
int atomicMass=0, nucleonCount=0, particlesMade=0, halfLifeCounter=100;
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
PImage backgroundImage, startScreen, pauseScreen, elementPad, protonCannonUp, neutronCannonUp, protonCannonNeutral, neutronCannonNeutral, protonCannonDown, neutronCannonDown, protonCannon, neutronCannon, pauseButton;
PImage[] protonImages, neutronImages;
boolean debugging=false, java=false, paused=true;

void setup () {
  size(512, 640);
  colorMode(RGB, 256);
  ellipseMode(CORNER);
  //orientation(PORTRAIT);
  frameRate(30);
  printIfDebugging("setup started");
  startScreen=loadImage("start-page.jpg");
  pauseScreen=loadImage("pause-page.jpg");
  //background (startScreen);
  image (startScreen, 0, 0, width, height);
  redraw();
  noLoop();
  nucleons=new Nucleon[300];
  doomed=new Nucleon[16];
  backgroundImage=loadImage("background-for-web-demo.jpg");
  elementPad=loadImage("element-pad.png");
  pauseButton=loadImage("pause.png");
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
  reset();
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
    //    background(startScreen);
    if (frameCount<2) {
      image(startScreen, 0, 0, width, height);
    }
    else {
      image(pauseScreen, 0, 0, width, height);
    }
    printIfDebugging("Paused but draw() called anyway");
  }
  else {
    if (!java && halfLifeCounter<6000) {
      getHalfLife(halfLifeCounter);
      halfLifeCounter+=1;
    }
    //printIfDebugging("Not paused");
    //background (backgroundImage);
    image (backgroundImage, 0, 0, width, height);
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


    for (int i=0; i<nucleonCount; i++) { // Position and mood updating  loop
      if (nucleons[i].active) {
        Nucleon thisNucleon=nucleons[i];
        thisNucleon.updatePosition();
        if (millis()>doomTime+2000 && thisNucleon.mood==OHNOEZ) { // Two seconds of vibratory grace
          thisNucleon.mood=BYEBYE;
          thisNucleon.moodTime=2000;
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
      if (halfLives[atomicNumber][neutrons]<5) { // Half-life of just a few seconds
        newMood=CONCERN;
      }
      else if (halfLives[atomicNumber][neutrons]<10000) { // Not *so* unstable
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
      for (int i=0; i<nucleonCount; i++) { // No nucleons should stay doomed
        nucleons[i].doomLevel=0;
        if (nucleons[i].mood==OHNOEZ || nucleons[i].mood==BYEBYE) { // OMG THE RELIEF
          nucleons[i].mood=WHEEE;
          nucleons[i].moodTime=500;
        }
      }

      if (decayTypes[atomicNumber][neutrons]==NEUTRON|decayTypes[atomicNumber][neutrons]==ELECTRON) {
        overallMood[0]=newMood;
        overallMood[1]=SMILE;
        doomed[0]=chooseNucleon(0);
      }
      else if (decayTypes[atomicNumber][neutrons]==PROTON|decayTypes[atomicNumber][neutrons]==POSITRON) {
        overallMood[1]=newMood;
        overallMood[0]=SMILE;
        doomed[0]=chooseNucleon(1);
      }
      else if (decayTypes[atomicNumber][neutrons]==HELIUM||decayTypes[atomicNumber][neutrons]==UNKNOWN) { // Assume alpha decay if unknown.
        overallMood[1]=newMood;
        overallMood[0]=newMood;
        doomed[0]=chooseNucleon(0);
        doomed[1]=chooseNucleon(1);
        doomed[2]=chooseNucleon(0);
        doomed[3]=chooseNucleon(1);
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
    textSize(20);
    textAlign(RIGHT);
    text(atomicNumber, 32, 64);
    text(atomicMass, 32, 100);
    textAlign(CENTER);
    if (elementNames[atomicNumber].length()>10) {
      textSize(180/elementNames[atomicNumber].length());
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
    image(pauseButton, 20, 20, 40, 60);
    //printIfDebugging(decayModes[atomicNumber][neutrons]);
    textAlign(LEFT);
    text("Decay mode: "+decayModes[atomicNumber][neutrons], 10, 50);
    text("Halflife: "+halfLives[atomicNumber][neutrons], 10, 70);
  }
}
Nucleon chooseNucleon(int charge) { // Choose the furthest matching nucleon from the centre, or the nearest to the latest already-doomed nucleon
  Nucleon currentNucleon;
  Nucleon chosenNucleon=protonOne;
  if (killList==0) { // If the kill list is empty, choose second-furthest from centre
    float greatestDistance=0;
    Nucleon furthestNucleon=protonOne;
    for (int i=0; i<nucleonCount; i++) {
      currentNucleon=nucleons[i];
      if (currentNucleon.charge==charge) { // Find the second-furthest one
        float distance=sqrt(currentNucleon.position.x*currentNucleon.position.x + currentNucleon.position.y*currentNucleon.position.y);
        if (distance>greatestDistance && currentNucleon.doomLevel==0) {
          greatestDistance=distance;
          chosenNucleon=furthestNucleon; // Second-furthest, now
          furthestNucleon=currentNucleon; 
        }
      }
    }
    if (chosenNucleon==protonOne) {
      chosenNucleon=furthestNucleon;
    }
  }
  else {  // If there are already items in the kill list, we're finding nearby nucleons
    float smallestDistance=1000000;
    for (int i=0; i<nucleonCount; i++) {
      currentNucleon=nucleons[i];
      if (currentNucleon.charge==charge) { // Find the nearest one
        float distance=sqrt(sq(currentNucleon.position.x-doomed[killList-1].position.x) + sq(currentNucleon.position.y-doomed[killList-1].position.y));
        if (distance<smallestDistance && currentNucleon.doomLevel==0) {
          smallestDistance=distance;
          chosenNucleon=currentNucleon;
        }
      }
    }
  }

  killList++;
  chosenNucleon.doomLevel=1;
  return chosenNucleon;
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
  if (key=='p') {
    // printIfDebugging("key p pressed");
    protonCannon=protonCannonDown;
  }
  if (key=='n') {
    // printIfDebugging("key n pressed");
    neutronCannon=neutronCannonDown;
  }
  if (key=='h' && paused==false) {
    paused=true;
    //background(startScreen);
    image(pauseScreen, 0, 0, width, height);
    noLoop();
    redraw();
  }
  else {
    paused=false;
    loop();
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
    reset();
  }
}


void mouseReleased() {
  if (paused) {
    if (mouseY>height*0.8 && mouseX<width*0.5) {
      reset();
    }
    paused=false;
    loop();
  }
  else {
    printIfDebugging("paused="+paused);
    if (mouseY<100) {
      image(pauseScreen, 0, 0, width, height);
      noLoop();
      redraw();
      paused=true;
    }
    else if (mouseX<width/2) {
      shootProton();
    }
    else if (mouseX>width/2) {
      shootNeutron();
    }
  }
}


void printIfDebugging (String message) {
  if (debugging) println(message);
}

void reset() {
  for (int i=0; i<nucleons.length; i++) {
    nucleons[i]=null;
  }
  nucleonCount=0;
  protonOne=new Proton(0, 0, 0, 0);
}

void loadData() {
  halfLives=new float[178][178];
  decayModes=new String[178][178];  
  decayTypes=new int[178][178];  
  if (java) {
    Table nuclides=loadTable("halflives.tsv", "header");
    for (int i=0; i<nuclides.getRowCount(); i++) {
      int protonCount=nuclides.getInt(i, 0);
      int neutronCount=nuclides.getInt(i, 1);
      float halfLife=nuclides.getFloat(i, 2); // We're taking the natural logarithm of the real halflife to bring things into human timescales

      //if (halfLife<0.1) halfLife=1;
      if (Float.isNaN(halfLife)) { 
        printIfDebugging("That's not a number: "+nuclides.getString(i, 2));
        if (nuclides.getString(i, 2).equals("infinity")) {
          halfLife=Float.MAX_VALUE;
          printIfDebugging("It's infinity.");
        }
        else {
          halfLife=0;
        }
      } 
      printIfDebugging("Z="+protonCount+", N="+neutronCount+", halfLife="+halfLife);
      halfLives[protonCount][neutronCount]=halfLife;
      String decayMode=nuclides.getString(i, 3);
      if (decayModes[protonCount][neutronCount]==null) decayModes[protonCount][neutronCount]=decayMode;
      decayTypes[protonCount][neutronCount]=UNKNOWN;
      if (decayMode!=null) {
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
    redraw();
    String[] namesAndSymbols=loadStrings("elementnames.tsv");
    printIfDebugging(namesAndSymbols[0]);
    for (int i=0; i<namesAndSymbols.length; i++) {
      String[] thisLine=splitTokens(namesAndSymbols[i]);
      printIfDebugging(thisLine[0]+ ", "+thisLine[1]+", "+thisLine[2]+", "+thisLine[3]);
      elementNames[i+1]=thisLine[2];
      elementSymbols[i+1]=thisLine[3];
    }
    halfLifeList=loadStrings("halflives.tsv");
    printIfDebugging("Got halfLifeList. Length: "+halfLifeList.length);
    halfLives=new float[178][178];
    printIfDebugging("Now to parse those halflives. First line is "+halfLifeList[0]);
    decayTypes=new int[178][178];
    for (int i=1; i<100 ; i++) {
      getHalfLife(i);
    }

    // End JS-only bit
  }
}

void getHalfLife(int i) {
  //    for (int i=1; i<nuclides.length; i++) {
  //if (i==nuclides.length-1) printIfDebugging("Decay-parsing loop "+i+" of "+nuclides.length);
  String[] thisLine=splitTokens(halfLifeList[i]);
  int protonCount=parseInt(thisLine[0]);
  int neutronCount=parseInt(thisLine[1]);
  float halfLife=parseInt(thisLine[2]);
  if (thisLine[2]=="infinity") {
    halfLife=10000000;
    printIfDebugging("Let's just pretend ten million is really infinity");
  }
  printIfDebugging("Z="+protonCount+", N="+neutronCount+", halfLife="+halfLife);
  halfLives[protonCount][neutronCount]=halfLife;
  //      String decayMode=thisLine[3];
        String decayMode="A";
  if (thisLine.length<4) {
    decayMode="Ah";
    printIfDebugging("thisLine.length<4");
  }
  else {
    decayMode=thisLine[3];
    printIfDebugging("thisLine.length>4");
  }
  printIfDebugging("thisLine.length="+thisLine.length);
  //decayMode="WTF";//decayMode;
  printIfDebugging ("decayMode="+decayMode);

  decayModes[protonCount][neutronCount]=decayMode;

  if (decayMode.charAt(0)=="A") { 
    printIfDebugging ("A");
    decayTypes[protonCount][neutronCount]=HELIUM;
  }
  else if (decayMode.charAt(0)=="E") {
    decayTypes[protonCount][neutronCount]=POSITRON;
  }
  else if (decayMode.charAt(0)=="B") {
    decayTypes[protonCount][neutronCount]=ELECTRON;
    printIfDebugging ("decayType diagnosed from 'B'");
  }
  else if (decayMode.charAt(0)=="P") {
    decayTypes[protonCount][neutronCount]=PROTON;
  }
  else if (decayMode.charAt(0)=="N") {
    decayTypes[protonCount][neutronCount]=NEUTRON;
  }
  else {
    decayTypes[protonCount][neutronCount]=UNKNOWN;
  }
  printIfDebugging("decayType="+decayTypes[protonCount][neutronCount]);
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
  Neutron (float x, float y, float vx, float vy) {
    super (x, y, vx, vy);
    this.sprite=neutronImages;
    this.charge=0;
    printIfDebugging("Neutron mood="+this.mood+" moodTime="+moodTime+" x="+this.position.x+" y="+this.position.y);
  }
}  

class Nucleon extends Particle { // It's possible this should be an interface
  boolean fixed=false;
  int mood, moodTime, doomLevel=0;
  float diameter;
  Nucleon (float x, float y, float vx, float vy) {
    super (x, y, vx, vy);
    mood=WHEEE; // A split second's excitement on entry
    moodTime=200;
    diameter=nucleonDiameter;
    int i=0;
    boolean replacement=false;
    while (i<nucleonCount) {
      if (!nucleons[i].active) {
        replacement=true;
        nucleons[i]=this;
        break;
      }
      i++;
    }
    if (!replacement) {
      nucleons[nucleonCount]=this;
      nucleonCount++;
    }
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
      //printIfDebugging("BYEBYE FORCE");
    }
    if (this.mood==OHNOEZ | that.mood==OHNOEZ) {
      attractionMultiplier*=0.8;
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
        if (magnitude>0.5 && attractionMultiplier==-1 && this.mood!=OHNOEZ) { // Express slight concern about bouncing
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
      else { // distSq<0.6
        PVector collisionPoint=new PVector((this.position.x+that.position.x)/2, (this.position.y+that.position.y)/2);
        PVector thisVector=PVector.sub(this.position, collisionPoint);
        float thisDistance=thisVector.mag();
        this.position.add(PVector.mult(thisVector, (this.diameter-thisDistance)/(2*this.diameter)));
        that.position.sub(PVector.mult(thisVector, (this.diameter-thisDistance)/(2*this.diameter)));
      }
    }
  }
  void drawSprite() {
    //printIfDebugging("Mood="+mood);
    image(sprite[mood], position.x, position.y);
  }
  void drawShadow() {
    noStroke();
    fill(0, 64);
    ellipse(position.x-5, position.y+5, 36, 36);
  }
  void updatePosition() {
    super.updatePosition();
    if (this.mood==OHNOEZ && this!=protonOne) {
      this.position.x+=vibrate;
      vibrate*=-1;
    }
  }
}

class Particle {
  PVector position;
  PVector velocity;
  PImage[] sprite;
  float mass;
  int charge;
  boolean linkedIn=false;
  boolean active=true;
  int particleIndex;
  float vibrate=2;
  //float x, y, vx, vy;
  Particle (float x, float y, float vx, float vy) {
    this.position=new PVector (x, y);
    this.velocity=new PVector (vx, vy);
    this.sprite=new PImage[1];
    //this.sprite[0]=loadImage("default.gif");
    this.particleIndex=particlesMade;
    particlesMade++;
    printIfDebugging("particlesMade="+particlesMade);
  }
  void updatePosition() {
    position.add(velocity);
    //float distFromCentre=mag(this.position.x,this.position.y);
    if (linkedIn) {
      position.add(new PVector(-position.y/500, position.x/500));
      velocity.mult(damping); // It may make more sense to apply damping once per linked particle elsewhere
    }

    //printIfDebugging("x: "+position.x+" y: "+position.y+" vx: "+velocity.x+" vy: "+velocity.y);
    if (abs(position.x)>width*5/8||abs(position.y)>height*5/8) { // Particle has escaped - mark it inactive and do nothing more with it
      printIfDebugging("doom time!");
      this.active=false;
    }
  }

  void drawSprite() {
    image(sprite[0].get(), position.x, position.y);
  }
}

class Proton extends Nucleon {
  Proton (float x, float y, float vx, float vy) {
    super (x, y, vx, vy);
    this.sprite=protonImages;
    this.charge=1;
    printIfDebugging("Proton mood on creation: "+this.mood+" x="+this.position.x+" y="+this.position.y);
  }
  void repel (Proton that) {
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


