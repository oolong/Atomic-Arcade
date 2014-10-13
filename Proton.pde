class Proton extends Nucleon {
  Proton (float x, float y, float vx, float vy){
    super (x, y, vx, vy);
    this.sprite=new PImage[6];
    for (int i=0; i<6; i++){
      this.sprite[i]=loadImage("proton"+i+".png");
    }
    this.charge=1;
    printIfDebugging("Proton mood on creation: "+this.mood+" x="+this.position.x+" y="+this.position.y);
  }
  void repel (Proton that){
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
