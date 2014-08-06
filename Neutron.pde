class Neutron extends Nucleon {
  Neutron (float x, float y, float vx, float vy){
    super (x, y, vx, vy);
    this.sprite[0]=loadImage("neutron.gif");
    this.charge=0;
  }
}  
