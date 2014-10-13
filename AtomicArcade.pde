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
PImage backgroundImage, helpScreen, elementPad, protonCannonUp, neutronCannonUp, protonCannonNeutral, neutronCannonNeutral, protonCannonDown, neutronCannonDown, protonCannon, neutronCannon;

boolean debugging=false, java=false, paused=true;

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
  protonOne=new Proton(0, 0, 0, 0);
  printIfDebugging("first proton brings nucleonCount to "+nucleonCount);
  nucleons[0]=protonOne; // Starting with a static hydrogen atom
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
  elementNames=new String[119];
  elementSymbols=new String[119];
  elementNames[0]="Nothing?";
  elementSymbols[0]="0";
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
  }
  else {
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
    