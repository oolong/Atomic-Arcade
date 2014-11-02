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
float nucleonDiameter=36;
float damping=0.99, vibrate=2;
int atomicNumber=0, neutrons=0, killList=0;
int atomicMass=0, nucleonCount=0, particlesMade=0, halfLifeCounter=100;
int neutronCannonCountdown=0, protonCannonCountdown=0, currentCannon=0;
final int SMILE=0, WHEEE=1, FROWN=2, CONCERN=3, OHNOEZ=4, BYEBYE=5;
final int NEUTRON=0, PROTON=1, POSITRON=2, ELECTRON=3, HELIUM=4, UNKNOWN=5, NONE=-1; // Alpha decay is 'HELIUM' because ALPHA is a reserved word
float zoomLevel=1;
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
boolean debugging=false, java=true, paused=true;

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
    if (atomicMass>39 