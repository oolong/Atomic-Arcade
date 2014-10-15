class Neutron extends Nucleon {
  Neutron (float x, float y, float vx, float vy) {
    super (x, y, vx, vy);
    this.sprite=neutronImages;
    this.charge=0;
    printIfDebugging("Neutron mood="+this.mood+" moodTime="+moodTime+" x="+this.position.x+" y="+this.position.y);
  }
}  

