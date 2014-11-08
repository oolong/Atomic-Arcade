import ddf.minim.*;

import processing.serial.*;

import cc.arduino.*;

Arduino arduino;
boolean arduinoised=true;

/* @pjs preload="circle-32.png, start-page.jpg, pause-page.jpg, background-for-web-demo.jpg, proton-cannon-down.png, proton-cannon-neutral.png, proton-cannon-up.png, neutron-cannon-down.png, neutron-cannon-neutral.png, neutron-cannon-up.png, background-square.jpg, element-pad.png, circle-xxl.png, default.gif, default.png, neutron.gif, neutron0.png, neutron1.png, neutron2.png, neutron3.png, neutron4.png, neutron5.png, proton.gif, proton0.png, proton1.png, proton2.png, proton3.png, proton4.png, proton5.png"; 
 */


Nucleon[] nucleons;
Nucleon[] doomed;
String[] halfLifeList; // To store half-life information.
String announcement="It all starts with hydrogen...";
float doomTime=1666;
float em=0.5; // Strength of the electromagnetic force
Proton protonOne;
float[] nuclearAttraction= { 
  0.25, 0.85, 0.005
}; // Neutron-neutron, proton-neutron, proton-proton nuclear force strength
float nuclearRepulsion=0.8;
float nucleonDiameter=36;
float damping=0.99, vibrate=2;
int atomicNumber=0, neutrons=0, killList=0, soundsLoaded=1;
int atomicMass=0, nucleonCount=0, particlesMade=0, halfLifeCounter=100;
int neutronCannonCountdown=0, protonCannonCountdown=0, currentCannon=0;
final int SMILE=0, WHEEE=1, FROWN=2, CONCERN=3, OHNOEZ=4, BYEBYE=5;
final int NEUTRON=0, PROTON=1, POSITRON=2, ELECTRON=3, HELIUM=4, UNKNOWN=5, NONE=-1; // Alpha decay is 'HELIUM' because ALPHA is a reserved word
String radiationNames[]= { 
  "Neutron", "Proton", "Beta+ (positron)", "Beta- (electron)", "Alpha"
};
final int NEUTRON_BUTTON=11, PROTON_BUTTON=12, HELP_BUTTON=13;
float zoomLevel=1;
float[][] halfLives;
String[][] decayModes;
int[][] decayTypes;
boolean[] elementMade;
boolean[] radiationEmitted;
String[] elementNames;
String[] elementSymbols;
String[] elementSnippets;
String[] elementSnippets2;
String snippet="";
String snippet2="";
AudioSample[] elementSounds;
int[] overallMood = { 
  0, 0
};
PImage backgroundImage, startScreen, pauseScreen, elementPad, protonCannonUp, neutronCannonUp, protonCannonNeutral, neutronCannonNeutral, protonCannonDown, neutronCannonDown, protonCannon, neutronCannon, pauseButton;
PImage[] protonImages, neutronImages;
Particle beta;
Minim minim;
AudioSample pop, pop2;

boolean debugging=true, java=true, paused=true, wasHigh=true, freshlyStarted=true;

void setup () {
  size(480, 640);
  colorMode(RGB, 256);
  ellipseMode(CORNER);
  //orientation(PORTRAIT);
  frameRate(30);
  printIfDebugging("setup started");

  if (arduinoised) {
    println(Arduino.list());
    arduino = new Arduino(this, Arduino.list()[0], 57600);
    for (int i = 0; i <= 13; i++) {
      arduino.pinMode(i, Arduino.INPUT);
    }
  }
  startScreen=loadImage("start-page.jpg");
  pauseScreen=loadImage("pause-page.jpg");
  //background (startScreen);
  image (startScreen, 0, 0, width, height);
  redraw();
  //noLoop();
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
  elementSnippets=new String[119];
  elementSnippets2=new String[119];
  elementMade=new boolean[119];
  elementMade[1]=true;
  radiationEmitted=new boolean[6];
  elementNames[0]="Nothing?";
  elementSymbols[0]="0";
  loadData(); // Note that this method needs commenting or uncommenting depending on mode

  reset();

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
    if (freshlyStarted) {
      image(startScreen, 0, 0, width, height);
    } 
    else {
      image(pauseScreen, 0, 0, width, height);
    }
    if (arduinoised) {
      if ((arduino.digitalRead(HELP_BUTTON)==Arduino.LOW || arduino.digitalRead(NEUTRON_BUTTON)==Arduino.LOW) && wasHigh) {
        paused=false;
        wasHigh=false;
      }
      if (arduino.digitalRead(HELP_BUTTON)==Arduino.HIGH && arduino.digitalRead(NEUTRON_BUTTON)==Arduino.HIGH && arduino.digitalRead(PROTON_BUTTON)==Arduino.HIGH) {
        wasHigh=true;
      }
      if (arduino.digitalRead(PROTON_BUTTON)==Arduino.LOW && wasHigh && !freshlyStarted) {
        reset();
        //paused=false;
      }
      if (arduino.digitalRead(PROTON_BUTTON)==Arduino.LOW && wasHigh && freshlyStarted) {
        paused=false;
      }
    }
  } 
  else {
    if (!java && halfLifeCounter<6000) {
      getHalfLife(halfLifeCounter);
      halfLifeCounter+=1;
    }
    //printIfDebugging("Not paused");
    //background (backgroundImage);
    if (freshlyStarted) {
      elementSounds[1].trigger();
      freshlyStarted=false;
    }


    image (backgroundImage, 0, 0, width, height);
    pushMatrix();
    translate(width/2, height/2);
    if (atomicMass>39  && atomicMass<119 && zoomLevel>0.8) {
      zoomLevel*=0.98;
    } 
    else if (atomicMass>119 && zoomLevel>0.67) {
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
    for (int i=0; i<nucleonCount; i++) { // Position and mood updating loop
      if (nucleons[i].active) {
        Nucleon thisNucleon=nucleons[i];
        thisNucleon.updatePosition();
        if (millis()>doomTime+2000 && thisNucleon.mood==OHNOEZ) { // Two seconds of vibratory grace
          if (decayTypes[atomicNumber][neutrons]==POSITRON) { // Beta+ decay
            thisNucleon.active=false;
            new Neutron(thisNucleon.position.x, thisNucleon.position.y, thisNucleon.velocity.x, thisNucleon.velocity.y);
            thisNucleon.velocity.x-=thisNucleon.position.x/20;
            thisNucleon.velocity.y-=thisNucleon.position.y/20;
            beta=new Positron(thisNucleon.position.x, thisNucleon.position.y,thisNucleon.position.x/10, thisNucleon.position.y/10);
          }
          else if (decayTypes[atomicNumber][neutrons]==ELECTRON) { // Beta- decay
            thisNucleon.active=false;
            new Proton(thisNucleon.position.x, thisNucleon.position.y, thisNucleon.velocity.x, thisNucleon.velocity.y);
            thisNucleon.velocity.x-=thisNucleon.position.x/20;
            thisNucleon.velocity.y-=thisNucleon.position.y/20;
            beta=new Electron(thisNucleon.position.x, thisNucleon.position.y,thisNucleon.position.x/10, thisNucleon.position.y/10);
          }
          else {
            thisNucleon.mood=BYEBYE;
            thisNucleon.moodTime=2000;
          }

          if (radiationEmitted[decayTypes[atomicNumber][neutrons]]==false && decayTypes[atomicNumber][neutrons]<radiationNames.length) {
            announcement=""+radiationNames[decayTypes[atomicNumber][neutrons]]+" radiation emitted!";
            radiationEmitted[decayTypes[atomicNumber][neutrons]]=true;
          }
        }
        if (thisNucleon.moodTime>0) thisNucleon.moodTime--;
        else if (thisNucleon.linkedIn) {
          //printIfDebugging("was "+thisNucleon.mood);
          thisNucleon.mood=overallMood[thisNucleon.charge];
        } 
        else {
          thisNucleon.mood=OHNOEZ; // UH OH, WHERE AM I GOING?! WHY IS EVERYONE FLOATING AWAY FROM ME?
        }
      }
    }
    if (beta!=null && beta.active==true){
      beta.updatePosition();
      beta.drawSprite();
    }
    if (millis()>doomTime && killList>0) { // Time to doom this thing
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
if (millis()>doomTime + 2000 && killList>0) { // Two second's grace period has elapsed.
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
    if (atomicNumber!=oldAtomicNumber||neutrons!=oldNeutrons && atomicNumber<119) { // New nuclide time
      // Announce new element if (atomicNumber!=oldAtomicNumber)
      // Here we establish how happy the protons and neutrons should be, and if one of them needs to decay
      int newMood=SMILE;
      if (elementMade[atomicNumber]==false) {
        announcement="You made "+elementNames[atomicNumber]+"!";
        snippet=elementSnippets[atomicNumber];
        snippet2=elementSnippets2[atomicNumber];
        elementMade[atomicNumber]=true;
        elementSounds[atomicNumber%10].trigger();
        printIfDebugging("sound triggered: "+atomicNumber+", "+elementSounds[atomicNumber%10].getMetaData().title());
        printIfDebugging("now to load: "+(atomicNumber+2)+", position "+soundsLoaded%10);
        if (elementSounds[(atomicNumber+2)%10]!=null) elementSounds[(atomicNumber+2)%10].close();
        if ((atomicNumber+2)<119) {
          elementSounds[(atomicNumber+2)%10]=minim.loadSample("mp3/"+(atomicNumber+2)+".mp3", 128);
        }
        printIfDebugging("sound loaded: "+(atomicNumber+2)+".mp3");
        soundsLoaded++;
      }
      else if (atomicNumber!=oldAtomicNumber && atomicNumber>1) {
        announcement="Back to "+elementNames[atomicNumber]+".";
        snippet="";
        snippet2="";
      }
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
      else { // If all else fails, smile
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
    if (elementNames[atomicNumber].length()>8) {
      textSize(160/elementNames[atomicNumber].length());
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
    if (arduinoised) {
      if (arduino.digitalRead(PROTON_BUTTON)==Arduino.HIGH && protonCannon==protonCannonDown) {
        shootProton();
      }    
      if (arduino.digitalRead(NEUTRON_BUTTON)==Arduino.HIGH && neutronCannon==neutronCannonDown) {
        shootNeutron();
      }
      if (arduino.digitalRead(HELP_BUTTON)==Arduino.LOW && wasHigh) {
        paused=true;
        wasHigh=false;
      }
      if (arduino.digitalRead(HELP_BUTTON)==Arduino.HIGH) {
        wasHigh=true;
      }
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
    if (arduinoised) {
      if (arduino.digitalRead(PROTON_BUTTON)==Arduino.LOW) {
        protonCannon=protonCannonDown;
      }
      if (arduino.digitalRead(NEUTRON_BUTTON)==Arduino.LOW) {
        neutronCannon=neutronCannonDown;
      }
    }
    image(protonCannon, 0, height-120, 120, 120);
    image(neutronCannon, width-120, height-120, 120, 120);
    //image(pauseButton, 20, 20, 40, 60);
    //printIfDebugging(decayModes[atomicNumber][neutrons]);
    textAlign(CENTER);
    textSize(20);
    text(announcement, width/2-30, 54);
    textSize(14);
    text(snippet, width/2-30, 78);
    text(snippet2, width/2-30, 100);
    //text("Decay mode: "+decayModes[atomicNumber][neutrons], 10, 50);
    //text("Halflife: "+halfLives[atomicNumber][neutrons], 10, 70);
  }
}
Nucleon chooseNucleon(int charge) { // Choose the furthest matching nucleon from the centre, or the nearest to the latest already-doomed nucleon
  Nucleon currentNucleon;
  Nucleon chosenNucleon=protonOne;
  if (killList==0) { // If the kill list is empty, choose furthest from centre
    float greatestDistance=0;
    Nucleon furthestNucleon=protonOne;
    for (int i=0; i<nucleonCount; i++) {
      currentNucleon=nucleons[i];
      if (currentNucleon.charge==charge && currentNucleon.doomLevel==0) { // Find the furthest one
        float distance=sqrt(currentNucleon.position.x*currentNucleon.position.x + currentNucleon.position.y*currentNucleon.position.y);
        if (distance>greatestDistance) {
          greatestDistance=distance;
          chosenNucleon=furthestNucleon;
          furthestNucleon=currentNucleon;
        }
      }
    }
    if (chosenNucleon==protonOne) {
      chosenNucleon=furthestNucleon; // Deal with edge case where there are only two protons
    }
  } 
  else { // If there are already items in the kill list, we're finding nearby nucleons
    float smallestDistance=1000000;
    for (int i=0; i<nucleonCount; i++) {
      currentNucleon=nucleons[i];
      if (currentNucleon.charge==charge) { // Find the furthest one
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
    pop.trigger();
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
    pop2.trigger();
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
  if (java) {
    minim = new Minim(this);
    elementSounds=new AudioSample[119];

    // load BD.wav from the data folder
    pop = minim.loadSample("pop.mp3", 128);
    pop2 = minim.loadSample("pop2.mp3", 128);
    soundsLoaded=2;
    for (int i=0; i<8; i++) { // Need all files to exist or this bit bugs out
      printIfDebugging("Element to load: "+soundsLoaded);      
      elementSounds[soundsLoaded%10]=minim.loadSample("mp3/"+soundsLoaded+".mp3", 128);
      //printIfDebugging("Element loaded: "+i);
      soundsLoaded++;
    }
    paused=true;
  }

  if (elementSounds[1]!=null) {
    elementSounds[1].close();
  }
  elementSounds[1]=minim.loadSample("mp3/1-"+(int)random(1, 14)+".mp3");
  freshlyStarted=true;
  for (int i=2; i<119; i++) {
    elementMade[i]=false;
  }
  elementMade[1]=true;
  elementMade[0]=true;
}
void loadData() {
  halfLives=new float[178][178];
  decayModes=new String[178][178];
  decayTypes=new int[178][178];
  if (java) {
    Table nuclides=loadTable("halflives.tsv", "header");
    for (int i=0; i<nuclides.getRowCount (); i++) {
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
        else if (decayMode==null) {
          decayTypes[protonCount][neutronCount]=NONE;
        }
      }
      printIfDebugging("decayType="+decayTypes[protonCount][neutronCount]);
    }
    Table namesAndSymbols=loadTable("elementnames.tsv");
    for (int i=0; i<namesAndSymbols.getRowCount (); i++) {
      int protonCount=namesAndSymbols.getInt(i, 0);
      String name=namesAndSymbols.getString(i, 2);
      String symbol=namesAndSymbols.getString(i, 3);
      String snippet=namesAndSymbols.getString(i, 4);
      printIfDebugging("Atomic Number="+protonCount+", name="+name+", symbol="+symbol);
      elementNames[protonCount]=name;
      elementSymbols[protonCount]=symbol;
      String snippet1="", snippet2="";
      if (snippet.length()>36){
        String[] snippetBits=splitTokens(snippet);
        int j=0;
        while (snippet1.length()<36){
          String[] twoBits={snippet1, snippetBits[j]};
          snippet1=join (twoBits, " ");
          j++;
        }
        while (j<snippetBits.length){
          String[] twoBits={snippet2, snippetBits[j]};
          snippet2=join (twoBits, " ");
          j++;
        }
      }
      else {
        snippet1=snippet;
      }
      elementSnippets[protonCount]=snippet1;
      elementSnippets2[protonCount]=snippet2;
      //halfLives[protonCount][neutronCount]=halfLife;
    } // End Java-only bit
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
    for (int i=1; i<100; i++) {
      getHalfLife(i);
    }
    // End JS-only bit
  }
}
void getHalfLife(int i) {
  /*
  // for (int i=1; i<nuclides.length; i++) {
   //if (i==nuclides.length-1) printIfDebugging("Decay-parsing loop "+i+" of "+nuclides.length);
   String[] thisLine=splitTokens(halfLifeList[i]);
   int protonCount=thisLine[0];
   int neutronCount=thisLine[1];
   float halfLife=thisLine[2];
   if (isNaN(parseFloat(halfLife))) {
   halfLife=10000000;
   printIfDebugging("Let's just pretend ten million is really infinity");
   }
   printIfDebugging("Z="+protonCount+", N="+neutronCount+", halfLife="+halfLife);
   halfLives[protonCount][neutronCount]=halfLife;
   // String decayMode=thisLine[3];
   // String decayMode="A";
   if (thisLine.length<4) {
   decayMode="Ah";
   printIfDebugging("thisLine.length<4");
   } else {
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
   } else if (decayMode.charAt(0)=="E") {
   decayTypes[protonCount][neutronCount]=POSITRON;
   } else if (decayMode.charAt(0)=="B") {
   decayTypes[protonCount][neutronCount]=ELECTRON;
   printIfDebugging ("decayType diagnosed from 'B'");
   } else if (decayMode.charAt(0)=="P") {
   decayTypes[protonCount][neutronCount]=PROTON;
   } else if (decayMode.charAt(0)=="N") {
   decayTypes[protonCount][neutronCount]=NEUTRON;
   } else if (decayMode==null) {
   decayTypes[protonCount][neutronCount]=NONE;
   }  else {
   decayTypes[protonCount][neutronCount]=UNKNOWN;
   }
   printIfDebugging("decayType="+decayTypes[protonCount][neutronCount]);
   */
}

