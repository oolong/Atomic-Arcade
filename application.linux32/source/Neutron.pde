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