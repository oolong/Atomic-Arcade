package processing.test.atomicarcade;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class AtomicArcade extends PApplet {

/* @pjs preload="circle-32.png, circle-xxl.png, default.gif, default.png, neutron.gif, neutron1.png, neutron2.png, neutron3.png, neutron4.png, proton.gif, proton0.png, proton1.png, proton2.png, proton3.png, proton4.png"; 
 */

ArrayList<Nucleon> nucleons;
ArrayList<Bond> bonds;
//ArrayList<Proton> protons;
float em=0.5f; // Strength of the electromagnetic force
Proton ProtonOne;
float[] nuclearAttraction={ 
  0.35f, 0.9f, 0.005f
}; // Neutron-neutron, proton-neutron, proton-proton nuclear force strength
float nuclearRepulsion=0.8f;
float nucleonDiameter=30;
float damping=0.99f;
int atomicNumber=0;
int atomicMass=0;
int SMILE=0, WHEEE=1, FROWN=2, CONCERN=3, OHNOEZ=4;
float zoomLevel=2;

public void setup () {
  //size(800, 600);
  orientation(LANDSCAPE);
  frameRate(30);
  nucleons=new ArrayList<Nucleon>();
  bonds=new ArrayList<Bond>();
  nucleons.add(new Proton(0, 0, 0, 0)); // Starting with a static hydrogen atom?
  ProtonOne=(Proton)nucleons.get(0);
  background (0);
  println("setup complete");
}

public void draw () {
  /* Modelling bit will consist of:
   * looping over all plausible combinations of nucleons and applying nuclear force
   * looping over all of the protons and repelling them from each other
   * adjusting all velocities
   * adjusting all positions
   */

  background (0);
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
  ProtonOne.position.mult(0.9f);
  ProtonOne.velocity.mult(0.9f);
  ProtonOne.linkedIn=true;
}

public void shootProton () {
  float relV=2*log((atomicNumber+9)/3);
  nucleons.add(new Proton (-width/(2*zoomLevel), height/(2*zoomLevel), relV, -relV*(height)/width));
}

public void shootNeutron () {
  float relV=2*log((atomicNumber+9)/3);
  nucleons.add(new Neutron (width/(2*zoomLevel), height/(2*zoomLevel), -relV, -relV*(height)/width));
}

public void keyPressed() {
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

public void mousePressed() {
  if (mouseX<width/2) {
    shootProton();
  }
  else {
    shootNeutron();
  }
}
/** Representing the strong nuclear force between two particles (probably invisibly). */
class Bond {
  Nucleon particle1;
  Nucleon particle2;
  float a=0.1f, b=-0.2f;
  
  Bond(Nucleon particle1, Nucleon particle2){
    this.particle1=particle1;
    this.particle2=particle2;
  }
  
  public void attract (){
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
    this.sprite=new PImage[5];
    for (int i=0; i<4; i++){
      this.sprite[i]=loadImage("neutron"+i+".png");
    }
    this.charge=0;
    println("Neutron mood on creation: "+this.mood+" moodTime: "+moodTime);
  }
}  
class Nucleon extends Particle { // It's possible this should be an interface
  boolean fixed=false;
  int mood, moodTime;
  Nucleon (float x, float y, float vx, float vy) {
    super (x, y, vx, vy);
    mood=WHEEE;
    moodTime=200;
  }

  public void attract (Nucleon that) {
    float distance=PVector.dist(this.position, that.position)/nucleonDiameter;
    if (distance<4) {
      if (this.linkedIn==true||that.linkedIn==true) {
        this.linkedIn=true;
        that.linkedIn=true;
      }
      if (distance>0.8f) {            
        int totalCharge=this.charge+that.charge;
        //println("beginning attract function");
        /** This will be called on each bond each time-step, 
         and update the velocities of the two particles based on the distance between them.
         This is something like +a/r^12-b/r^6 I think. */
        //println("distance calculated");
        float magnitude=nuclearRepulsion*pow(distance, -8)-nuclearAttraction[totalCharge]*pow(distance, -5);
        //println("magnitude calculated");
        PVector force=(PVector.sub(this.position, that.position));//.heading();
        //println("angle calculated");
        //PVector force=PVector.fromAngle(angle);
        //println("force created");
        //println("force has magnitude "+force.mag()+" but it should be "+magnitude);
        //println("force has angle "+force.heading());
        force.normalize();
        force.mult(magnitude);
        //println("magnitude set");
        this.velocity.add(force);
        that.velocity.sub(force);
        if (magnitude>0.5f) { // Express slight concern about bouncing
          this.mood=FROWN;
          that.mood=FROWN;
          this.moodTime=10;
          that.moodTime=10;
          if (this.mood!=FROWN){
            this.velocity.mult(0.5f);
            that.velocity.mult(0.5f);
          }
        }
        //println("Attracting: Particle 1 at "+particle1.velocity.x+", "+particle1.velocity.y+" and 2 at "+particle2.velocity.x+", "+particle2.velocity.y);
      } else {
        PVector collisionPoint=new PVector((this.position.x+that.position.x)/2, (this.position.y+that.position.y)/2);
        PVector thisVector=PVector.sub(this.position, collisionPoint);
        float thisDistance=thisVector.mag();
        this.position.add(PVector.mult(thisVector, (nucleonDiameter-thisDistance)/(2*nucleonDiameter)));
        that.position.sub(PVector.mult(thisVector, (nucleonDiameter-thisDistance)/(2*nucleonDiameter)));
      }
    }
  }
  public void drawSprite() {
    image(sprite[mood].get(), position.x, position.y, 30, 30);
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
  public void updatePosition(){
    position.add(velocity);
    //float distFromCentre=mag(this.position.x,this.position.y);
    if (linkedIn) {
      position.add(new PVector(-position.y/500, position.x/500));
      velocity.mult(damping); // It may make more sense to apply damping once per linked particle elsewhere
    }
       
    //println("x: "+position.x+" y: "+position.y+" vx: "+velocity.x+" vy: "+velocity.y);
    if (abs(position.x)>width*5/8||abs(position.y)>height*5/8) {
      println("doom time! x="+position.x+", y="+position.y);
      nucleons.remove(this);
    }
  }
  
  public void drawSprite(){
    image(sprite[0].get(), position.x, position.y, 30, 30);
  }
}
class Proton extends Nucleon {
  Proton (float x, float y, float vx, float vy){
    super (x, y, vx, vy);
    this.sprite=new PImage[5];
    for (int i=0; i<4; i++){
      this.sprite[i]=loadImage("proton"+i+".png");
    }
    this.charge=1;
    println("Proton mood on creation: "+this.mood);
  }
  public void repel (Proton that){
    // calculate distance and angle, alter velocities
    PVector difference=PVector.sub (this.position, that.position);
    float distSq=sq(difference.x)+sq(difference.y); // Use Pythagoras to get the square of the distance between the vectors
    float magnitude=em/distSq;
    PVector force=(PVector.sub (this.position, that.position));//.heading();
    force.normalize();
    force.mult (magnitude);
    //println ("repelling by "+magnitude);
    if (this.fixed!=true) {
      this.velocity.add(force);
    }
    if (that.fixed!=true) {
      that.velocity.sub (force);
    }    
  }  
}

}
