import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import processing.serial.*; 
import cc.arduino.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class AtomicArcade extends PApplet {


//import minim.js;





Arduino arduino;
boolean arduinoised=false;

/* @pjs preload="circle-32.png, refresh-button.png, start-page.jpg, pause-page.jpg, background-for-web-demo.jpg, proton-cannon-down.png, proton-cannon-neutral.png, proton-cannon-up.png, neutron-cannon-down.png, neutron-cannon-neutral.png, neutron-cannon-up.png, background-square.jpg, element-pad.png, circle-xxl.png, default.gif, default.png, neutron.gif, neutron0.png, neutron1.png, neutron2.png, neutron3.png, neutron4.png, neutron5.png, proton.gif, proton0.png, proton1.png, proton2.png, proton3.png, proton4.png, proton5.png"; 
 */


Nucleon[] nucleons;
Nucleon[] doomed;
String[] halfLifeList; // To store half-life information.
String[] credits;
String announcement="";
float doomTime=1666;
float em=0.5f; // Strength of the electromagnetic force
Proton protonOne;
float[] nuclearAttraction= { 
  0.25f, 0.85f, 0.005f
}; // Neutron-neutron, proton-neutron, proton-proton nuclear force strength
float nuclearRepulsion=0.8f;
float nucleonDiameter=36;
float damping=0.99f, vibrate=2;
int atomicNumber=0, neutrons=0, killList=0, soundsLoaded=1, gracePeriod=2000;
int atomicMass=0, nucleonCount=0, particlesMade=0, halfLifeCounter=100, finishTime=0;
int neutronCannonCountdown=0, protonCannonCountdown=0, currentCannon=0;
final int SMILE=0, WHEEE=1, FROWN=2, CONCERN=3, OHNOEZ=4, BYEBYE=5;
final int NEUTRON=0, PROTON=1, POSITRON=2, ELECTRON=3, HELIUM=4, UNKNOWN=5, NONE=-1; // Alpha decay is 'HELIUM' because ALPHA is a reserved word
String radiationNames[]= { 
  "Neutron", "Proton", "Beta+", "Beta-", "Alpha"
};
String[] radiationSnippets= { 
  "A neutral particle", "A positively charged particle", "Positron: the anti-electron", "An electron", "A helium nucleus"
};
final int NEUTRON_BUTTON=11, PROTON_BUTTON=12, HELP_BUTTON=13;
float zoomLevel=1;
float[][] halfLives;
String[][] decayModes;
int[][] decayTypes;
boolean[] elementMade;
int[] radiationEmitted;
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
PImage backgroundImage, startScreen, pauseScreen, elementPad, refreshButton, protonCannonUp, neutronCannonUp, protonCannonNeutral, neutronCannonNeutral, protonCannonDown, neutronCannonDown, protonCannon, neutronCannon, pauseButton;
PImage[] protonImages, neutronImages;
Particle beta;
Minim minim;
AudioSample pop, pop2;

boolean debugging=false, java=true, paused=true, wasHigh=true, freshlyStarted=true, finished=false, loading=!java;

public void setup () {
  size(480, 640);
  colorMode(RGB, 256);
  ellipseMode(CORNER);
  //orientation(PORTRAIT);
  frameRate(30);
  printIfDebugging("setup started");

  if (arduinoised) {/*
    println(Arduino.list());
    arduino = new Arduino(this, Arduino.list()[0], 57600);
    for (int i = 0; i <= 13; i++) {
      arduino.pinMode(i, Arduino.INPUT);
    }*/
  }
  startScreen=loadImage("start-page.jpg");
  pauseScreen=loadImage("pause-page.jpg");

  //background (startScreen);
  image (startScreen, 0, 0, width, height);
  //redraw();
  //noLoop();
  nucleons=new Nucleon[500];
  doomed=new Nucleon[16];
  backgroundImage=loadImage("background-for-web-demo.jpg");
  elementPad=loadImage("element-pad.png");
  pauseButton=loadImage("pause.png");
  printIfDebugging("pause button loaded");
  refreshButton=loadImage("refresh-button.png");
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
  radiationEmitted=new int[6];
  elementNames[0]="Nothing?";
  elementSymbols[0]="0";
  printIfDebugging("All done bar the data");
  loadData(); // Note that this method needs commenting or uncommenting depending on mode

  reset();

  printIfDebugging("setup complete - nucleonCount="+nucleonCount);
  //redraw();
}

public void draw () {
  /* Modelling bit will consist of:
   * looping over all plausible combinations of nucleons and applying nuclear force
   * looping over all of the protons and repelling them from each other
   * adjusting all velocities
   * adjusting all positions
   */

  if (!java && loading) {
    for (int i=0; i<20; i++) {
      if (halfLifeCounter==halfLifeList.length) {
        loading=false;
        break;
      }
      getHalfLife(halfLifeCounter);
      halfLifeCounter+=1;
    }
  }
  if (paused) {
    //    background(startScreen);
    if (freshlyStarted) {
      image(startScreen, 0, 0, width, height);
    } 
    else {
      image(pauseScreen, 0, 0, width, height);
    }
    if (arduinoised) {/*
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
      }*/
    }
  } 
  else {

    //printIfDebugging("Not paused");
    //background (backgroundImage);
    if (freshlyStarted) {
      if (java) {
        elementSounds[1].trigger();
      }
      freshlyStarted=false;
    }


    image (backgroundImage, 0, 0, width, height);
    pushMatrix();
    translate(width/2, height/2);
    if (atomicMass>39  && atomicMass<119 && zoomLevel>0.8f) {
      zoomLevel*=0.98f;
    } 
    else if (atomicMass>119 && zoomLevel>0.67f) {
      zoomLevel*=0.98f;
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
        if (millis()>doomTime+gracePeriod && thisNucleon.mood==OHNOEZ) { // Two seconds of vibratory grace
          printIfDebugging("2 seconds elapsed, apparently - current millis="+millis()+", doomTime="+doomTime);
          if (decayTypes[atomicNumber][neutrons]==POSITRON) { // Beta+ decay
            thisNucleon.active=false;
            new Neutron(thisNucleon.position.x, thisNucleon.position.y, thisNucleon.velocity.x-thisNucleon.position.x/20, thisNucleon.velocity.y-thisNucleon.position.y/20);
            beta=new Positron(thisNucleon.position.x, thisNucleon.position.y, thisNucleon.position.x/10, thisNucleon.position.y/10);
          }
          else if (decayTypes[atomicNumber][neutrons]==ELECTRON) { // Beta- decay
            thisNucleon.active=false;
            new Proton(thisNucleon.position.x, thisNucleon.position.y, thisNucleon.velocity.x-thisNucleon.position.x/20, thisNucleon.velocity.y-thisNucleon.position.y/20);
            beta=new Electron(thisNucleon.position.x, thisNucleon.position.y, thisNucleon.position.x/10, thisNucleon.position.y/10);
          }
          else {
            thisNucleon.mood=BYEBYE;
            thisNucleon.moodTime=2000;
          }

          if (radiationEmitted[decayTypes[atomicNumber][neutrons]]==0 && decayTypes[atomicNumber][neutrons]<radiationNames.length) {
            println("atomicNumber="+atomicNumber+" neutrons="+neutrons+" decayTypes[atomicNumber][neutrons]="+decayTypes[atomicNumber][neutrons]+" radiation="+radiationNames[decayTypes[atomicNumber][neutrons]]);
            announcement=""+radiationNames[decayTypes[atomicNumber][neutrons]]+" radiation emitted!";
            if (decayTypes[atomicNumber][neutrons]>1&&decayTypes[atomicNumber][neutrons]!=HELIUM) {
              radiationEmitted[decayTypes[atomicNumber][neutrons]]++;
            }
            snippet=radiationSnippets[decayTypes[atomicNumber][neutrons]];
            snippet2="";
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
    if (beta!=null && beta.active==true) {
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
    if ((atomicNumber!=oldAtomicNumber||neutrons!=oldNeutrons) && atomicNumber<119) { // New nuclide time
      // Announce new element if (atomicNumber!=oldAtomicNumber)
      // Here we establish how happy the protons and neutrons should be, and if one of them needs to decay
      if (atomicNumber==118) {
        finished=true;
        finishTime=millis();
      }
      if (atomicNumber==5){ // Once you've made it to boron you're past the first three horribly unstable elements
        gracePeriod=2000; 
      }
      int newMood=SMILE;
      if (elementMade[atomicNumber]==false) {
        announcement="You made "+elementNames[atomicNumber]+"!";
        snippet=elementSnippets[atomicNumber];
        snippet2=elementSnippets2[atomicNumber];
        elementMade[atomicNumber]=true;
        if (java) {
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
      }
      else if (atomicNumber!=oldAtomicNumber && atomicNumber>1) {
        announcement="Back to "+elementNames[atomicNumber]+".";
        snippet="";
        snippet2="";
      }
      float halfLife=0;
      if (neutrons<halfLives[1].length) {
        halfLife=halfLives[atomicNumber][neutrons];
      }
      else {
        halfLife=0;
      }
      if (halfLife<5) { // Half-life of just a few seconds
        newMood=CONCERN;
      } 
      else if (halfLife<10000) { // Not *so* unstable
        newMood=FROWN;
      } 
      else { //
        overallMood[1]=SMILE;
        overallMood[0]=SMILE;
      }

      doomTime=abs((int)(millis()+1000*halfLife*random(0, 1)/random(0, 1))); // Doom time is set within an infinite range centred on the half-life.
      //println("doomTime="+doomTime);
      printIfDebugging("Doom will be in "+(doomTime-millis())+" milliseconds, at "+doomTime);
      printIfDebugging("millis now="+millis()+", random(0,1)="+random(0, 1));
      killList=0;
      for (int i=0; i<nucleonCount; i++) { // No nucleons should stay doomed
        nucleons[i].doomLevel=0;
        if (nucleons[i].mood==OHNOEZ||nucleons[i]==protonOne) { // OMG THE RELIEF
          nucleons[i].mood=WHEEE;
          nucleons[i].moodTime=500;
        }
      }
      int decayType=0;
      if (neutrons>decayTypes[1].length) {
        decayType=HELIUM;
      }
      else {
        decayType=decayTypes[atomicNumber][neutrons];
      }
      if (decayType==NEUTRON|decayType==ELECTRON) {
        overallMood[0]=newMood;
        overallMood[1]=SMILE;
        doomed[0]=chooseNucleon(0);
      } 
      else if (decayType==PROTON|decayType==POSITRON) {
        overallMood[1]=newMood;
        overallMood[0]=SMILE;
        doomed[0]=chooseNucleon(1);
      } 
      else if (decayType==HELIUM||decayType==UNKNOWN) { // Assume alpha decay if unknown.
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
      printIfDebugging("New Element: "+atomicNumber+" Half life: "+halfLife+" Decay type: "+decayType);
    }
    protonOne.position.mult(0.9f);
    protonOne.velocity.mult(0.9f);
    protonOne.linkedIn=true;
    popMatrix();
    pushMatrix();
    translate(width-120, 0);
    scale(0.8f);
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
    if (atomicNumber<119) {
      if (elementNames[atomicNumber].length()>8) {
        textSize(160/elementNames[atomicNumber].length());
      }
      text(elementNames[atomicNumber], 60, 122);
    }
    popMatrix();
    protonCannonCountdown--;
    neutronCannonCountdown--;
    if (protonCannonCountdown==4) {
      protonCannon=protonCannonUp;
    }
    if (neutronCannonCountdown==4) {
      neutronCannon=neutronCannonUp;
    }
    if (arduinoised) {/*
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
      }*/
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
    if (arduinoised) {/*
      if (arduino.digitalRead(PROTON_BUTTON)==Arduino.LOW) {
        protonCannon=protonCannonDown;
      }
      if (arduino.digitalRead(NEUTRON_BUTTON)==Arduino.LOW) {
        neutronCannon=neutronCannonDown;
      }*/
    }
    image(protonCannon, 0, height-120, 120, 120);
    image(neutronCannon, width-120, height-120, 120, 120);
    //image(pauseButton, 20, 20, 40, 60);
    //printIfDebugging(decayModes[atomicNumber][neutrons]);
    textAlign(CENTER);
    textSize(20);
    text(announcement, width/2, height-70);
    textSize(14);
    text(snippet, width/2, height-40);
    text(snippet2, width/2, height-20);
    textAlign(LEFT);
    int geiger=0;
    for (int i=0; i<radiationNames.length; i++) {
      geiger+=radiationEmitted[i];
      //if (radiationEmitted[i]>0){
      //text (radiationNames[i]+": "+radiationEmitted[i], 22, 52+18*i);
      //}
    }
    text ("Radiation count: "+geiger, 24, 42);
    //text("Decay mode: "+decayModes[atomicNumber][neutrons], 10, 50);
    //text("Halflife: "+halfLives[atomicNumber][neutrons], 10, 70);
    if (finished==true) {
      endScreen();
    }
  }
  if (loading) {
    pushMatrix();
    translate(width-60, 50);
    rotate(frameCount*0.3f);
    image(refreshButton, -30, -30, 60, 54);
    popMatrix();
  }
}
public Nucleon chooseNucleon(int charge) { // Choose the furthest matching nucleon from the centre, or the nearest to the latest already-doomed nucleon
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
        if (distance<smallestDistance && currentNucleon.doomLevel==0 && currentNucleon!=protonOne) {
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
public void shootProton () {
  if (protonCannonCountdown<1 && !finished) {
    if (java) {
      pop.trigger();
    }
    protonCannon=protonCannonNeutral;
    protonCannonCountdown=12;
    currentCannon=0;
    //float relV=2*log((atomicNumber+9)/3);
    float relV=3;
    new Proton (-width/(2*zoomLevel)+42, height/(2*zoomLevel)-74, relV, -relV*(height)/width);
  }
}
public void shootNeutron () {
  if (neutronCannonCountdown<1 && !finished) {
    if (java) {
      pop2.trigger();
    }
    printIfDebugging("shootNeutron called");
    neutronCannon=neutronCannonNeutral;
    neutronCannonCountdown=12;
    currentCannon=1;
    //float relV=2*log((atomicNumber+9)/3);
    float relV=3;
    new Neutron (width/(2*zoomLevel)-66, height/(2*zoomLevel)-74, -relV, -relV*(height)/width);
    printIfDebugging("Neutron may have been created?");
  }
}
public void keyPressed() {
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
public void keyReleased() {
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
public void mouseReleased() {
  if (paused) {
    if (mouseY>height*0.8f && mouseX<width*0.5f) {
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
public void printIfDebugging (String message) {
  if (debugging) println(message);
}
public void reset() {
  for (int i=0; i<nucleons.length; i++) {
    nucleons[i]=null;
  }
  nucleonCount=0;
  protonOne=new Proton(0, 0, 0, 0);
  if (java) {
    minim = new Minim(this);
    elementSounds=new AudioSample[119];
    // load BD.wav from the data folder
    if (pop==null) {
      pop = minim.loadSample("pop.mp3", 128);
      pop2 = minim.loadSample("pop2.mp3", 128);
    }
    soundsLoaded=2;
    for (int i=2; i<12; i++) { // Need all files to exist or this bit bugs out
      printIfDebugging("Element to load: "+soundsLoaded);   
      if (elementSounds[i%10]!=null) {
        elementSounds[i%10].close();
      }
      elementSounds[i%10]=minim.loadSample("mp3/"+i+".mp3", 128);
      //printIfDebugging("Element loaded: "+i);
      soundsLoaded++;
    }
    if (elementSounds[1]!=null) {
      elementSounds[1].close();
    }
    elementSounds[1]=minim.loadSample("mp3/1-"+(int)random(1, 15)+".mp3");
  }
  paused=true;


  freshlyStarted=true;
  gracePeriod=5000;
  for (int i=2; i<119; i++) {
    elementMade[i]=false;
  }
  for (int i=0; i<radiationEmitted.length; i++) {
    radiationEmitted[i]=0;
  }
  announcement="It all starts with hydrogen";
  snippet="92% of all atoms in the universe";
  elementMade[1]=true;
  elementMade[0]=true;
  finished=false;
}
public void loadData() {
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
      if (snippet.length()>36) {
        String[] snippetBits=splitTokens(snippet);
        int j=0;
        while (snippet1.length ()<36) {
          String[] twoBits= {
            snippet1, snippetBits[j]
          };
          snippet1=join (twoBits, " ");
          j++;
        }
        while (j<snippetBits.length) {
          String[] twoBits= {
            snippet2, snippetBits[j]
          };
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
    //redraw();
    String[] namesAndSymbols=loadStrings("elementnames.tsv");
    printIfDebugging(namesAndSymbols[0]);
    for (int i=0; i<namesAndSymbols.length; i++) {
      String[] thisLine=splitTokens(namesAndSymbols[i], "\t");
      printIfDebugging(thisLine[0]+ ", "+thisLine[1]+", "+thisLine[2]+", "+thisLine[3]);
      elementNames[i+1]=thisLine[2];
      elementSymbols[i+1]=thisLine[3];
      String snippet=thisLine[4];
      String snippet1="", snippet2="";
      if (snippet.length()>36) {
        String[] snippetBits=splitTokens(snippet);
        int j=0;
        while (snippet1.length ()<36) {
          String[] twoBits= {
            snippet1, snippetBits[j]
          };
          snippet1=join (twoBits, " ");
          j++;
        }
        while (j<snippetBits.length) {
          String[] twoBits= {
            snippet2, snippetBits[j]
          };
          snippet2=join (twoBits, " ");
          j++;
        }
      }
      else {
        snippet1=snippet;
      }
      elementSnippets[i+1]=snippet1;
      elementSnippets2[i+1]=snippet2;
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
  credits=loadStrings("credits.txt");
}
public void getHalfLife(int i) {
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
  if (halfLives[protonCount][neutronCount]==0) {
    halfLives[protonCount][neutronCount]=halfLife;
    // String decayMode=thisLine[3];
    // String decayMode="A";
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
    else if (decayMode==null) {
      decayTypes[protonCount][neutronCount]=NONE;
    }  
    else {
      decayTypes[protonCount][neutronCount]=UNKNOWN;
    }
  }
  printIfDebugging("decayType="+decayTypes[protonCount][neutronCount]);
*/}

public void endScreen() {
  //printIfDebugging("Finished!");
  //println("Finished!");
  randomSeed(3);
  fill(0, 192);
  rect(0, 0, width, height);
  textAlign(CENTER);
  textSize(20);
  fill(255);
  int imageSize=42;
  for (int i=0; i<6; i++) {
    image (neutronImages[PApplet.parseInt(random(1, 2))], random(0, width-imageSize), height-(random(height)+(millis()-finishTime)/100)%height, imageSize, imageSize);
    image (protonImages[PApplet.parseInt(random(1, 2))], random(0, width-imageSize), height-(random(height)+(millis()-finishTime)/100)%height, imageSize, imageSize);
  }
  for (int i=0; i<credits.length; i++) {
    text (credits[i], width/2, height-(millis()-finishTime)/20+i*24);
  }
}

class Electron extends Particle {
  // May not need anything much added besides the right sprite.
  Electron (float x, float y, float vx, float vy){
    super (x,y,vx,vy);
    this.sprite[0]=loadImage("electron.png");
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
    this.baryonNumber=1;
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

  public void attract (Nucleon that) {
    //float distance=PVector.dist(this.position, that.position)/this.diameter;
    PVector diff=PVector.sub(this.position, that.position);
    float distSq=(sq(diff.x)+sq(diff.y))/sq(this.diameter);
    //text(distSq, 100,100);
    //text(sq(this.diameter), 100,120);
    float attractionMultiplier=-1;
    if (this.mood==BYEBYE ^ that.mood==BYEBYE) { // If one of these particles is going byebye, repel it
      attractionMultiplier=1.8f;
      //printIfDebugging("BYEBYE FORCE");
    }
    if (this.mood==OHNOEZ | that.mood==OHNOEZ) {
      attractionMultiplier*=0.8f;
    }

    if (distSq<10) {
      if ((this.linkedIn==true||that.linkedIn==true)&&distSq<4) { // Only counts if they've slowed down
        this.linkedIn=true;
        that.linkedIn=true;
      }
      if (distSq>0.6f) {            
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
        if (magnitude>0.5f && attractionMultiplier==-1 && this.mood!=OHNOEZ && this.mood!=BYEBYE) { // Express slight concern about bouncing
          if (this.mood!=FROWN) {
            this.velocity.mult(0.5f);
            that.velocity.mult(0.5f);
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
  public void drawSprite() {
    //printIfDebugging("Mood="+mood);
    image(sprite[mood], position.x, position.y);
  }
  public void drawShadow() {
    noStroke();
    fill(0, 64);
    ellipse(position.x-5, position.y+5, 36, 36);
  }
  public void updatePosition() {
    super.updatePosition();
    if (this.mood==OHNOEZ && this!=protonOne) {
      this.position.x+=vibrate;
      vibrate*=-1;
      if (decayTypes[atomicNumber][neutrons]==POSITRON || decayTypes[atomicNumber][neutrons]==ELECTRON) { // Beta decay
        if (random(0,1)>0.5f){
          this.sprite=neutronImages;
        }
        else {
          this.sprite=protonImages;
        }
      }
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
  int baryonNumber=0;
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
  public void updatePosition() {
    position.add(velocity);
    //float distFromCentre=mag(this.position.x,this.position.y);
    if (linkedIn) {
      position.add(new PVector(-position.y/500, position.x/500));
      velocity.mult(damping); // It may make more sense to apply damping once per linked particle elsewhere
    }

    //printIfDebugging("x: "+position.x+" y: "+position.y+" vx: "+velocity.x+" vy: "+velocity.y);
    if ((abs(position.x)>width*5/(8*zoomLevel)||abs(position.y)>height*5/(8*zoomLevel)) && this.linkedIn==false) { // Particle has escaped - mark it inactive and do nothing more with it
      printIfDebugging("doom time!");
      this.active=false;
      if (this.baryonNumber==1){
        radiationEmitted[this.charge]++;
      }
    }
  }

  public void drawSprite() {
    image(sprite[0].get(), position.x, position.y);
  }
}

class Positron extends Particle {
  // May not need anything much added besides the right sprite.
  Positron (float x, float y, float vx, float vy){
    super (x,y,vx,vy);
    this.sprite[0]=loadImage("positron.png");
    this.charge=1;
  }
}
class Proton extends Nucleon {
  Proton (float x, float y, float vx, float vy) {
    super (x, y, vx, vy);
    this.sprite=protonImages;
    this.charge=1;
    printIfDebugging("Proton mood on creation: "+this.mood+" x="+this.position.x+" y="+this.position.y);
  }
  public void repel (Proton that) {
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

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "AtomicArcade" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
