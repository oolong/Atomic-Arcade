class Neutron extends Nucleon {
  Neutron (float x, float y, float vx, float vy) {
    super (x, y, vx, vy);
    this.sprite=new PImage[6];
    for (int i=0; i<6; i++) {
      this.sprite[i]=neutronImages[i];
    }
    this.charge=0;
    printIfDebugging("Neutron mood="+this.mood+" moodTime="+moodTime+" x="+this.position.x+" y="+this.position.y);
  }
}  

