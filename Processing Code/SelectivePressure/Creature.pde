/**List of ACTIVE creatures*/
ArrayList<Creature> creatures = new ArrayList<Creature>();
/**List of creatures that have died and should be removed*/
ArrayList<Creature> toRemove = new ArrayList<Creature>();
/**List of creatures that have just been born and want to be active*/
ArrayList<Creature> toAdd = new ArrayList<Creature>();
/**Used to calculate the average size*/
float avgSize = 0;
/**The minimum size a creature can be*/
final float minSize = 10;
/**The maximum size a creature can be*/
final float maxSize = 50;
/**The range of sizes we have between min and max*/
final float sizeRange = maxSize - minSize;
/**The amount of size change chance from your parent*/
final float sizeMutation = 5;
/**Every %birthrate%  frames you can get a child*/
final int birthRate = 60;//Amount of frames between birth attempts
/**Reference to the center screen so the creatures can navigate to it easily*/
final PVector center = new PVector();

/**
 A single creature
 **/
class Creature {
  //The position within the world of the creature
  PVector pos;
  //The velocity of the creature
  PVector vel;
  //The size of the creature
  float size;
  //The internal temperature of the creature
  float temp = 37;
  //Age, how many frames this creature has lived. Every 60 frames a creature can spawn a new one
  int age = 0;
  //We have a hundred energy to regulate temperature, and give birth
  float energy = 200;
  //If we're dead
  boolean dead = false;
  //The opacity we have right now
  float opacity = 1;
  //The color we draw this creature with
  color c;

  /**
   Creates a new creature at a random position
   **/
  Creature() {
    //Create at a random position
    pos = new PVector(random(width), random(height)); 
    vel = PVector.random2D();
    size = random(sizeRange) + minSize;
    age = (int) random(birthRate);
    c = color(20, map(size, minSize, maxSize, 0, 255), 125);
  }

  /**
   Creates a new creature from the provided parent
   **/
  Creature(Creature parent) {
    pos = parent.pos.copy();
    vel = PVector.random2D();
    size = parent.size + random(-sizeMutation, sizeMutation);
    size = constrain(size, minSize, maxSize);
    c = color(map(size, minSize, maxSize, 20, 30), map(size, minSize, maxSize, 0, 255), 125);
  }

  /**
   Updates this one creature
   **/
  float update() {
    //Add velocity to the position
    pos.add(vel);
    //And randomly turn a little
    PVector diff = PVector.sub(center, pos).limit(1).mult(0.05);
    vel.add(vel.copy().normalize().rotate(random(-QUARTER_PI, QUARTER_PI)).mult(0.3));
    vel.add(diff);
    vel.mult(map(size, minSize, maxSize, 0.8, 0.95));
    age ++;

    //Add a small force to the center


    //Wrap around the screen
    if (pos.x > width) pos.x = 0;
    else if (pos.x < 0) pos.x = width;
    if (pos.y > height) pos.y = 0;
    else if (pos.y < 0) pos.y = height;

    //And finally render ourselves
    render();

    //Increase our temperature by one degree just for living a turn
    temp += 0.5;

    //Now decrease depending on size
    temp -= map(size, 0, maxSize, 1, -1);

    //And depending on ambient cool down a little
    temp -= (temp - ambientTemp) * 0.05;

    //Aim for 37 celsius, otherwise use energy to keep heat good
    float tempDiff = (temp - 37) * 0.1;
    temp += tempDiff;
    energy -= abs(tempDiff) * 0.3;

    //The energy needed just to stay alive
    energy -= 0.5;
    //Check if we can give birth
    if (age % birthRate == 0) {
      //Only give birth if the random die roll determines we have a chance to do so
      if (random(70 + creatures.size()) < energy) giveBirth();
      else if (random(100) < energy) die();
    }
    //Return the size so we can calc the average
    if (energy < 0) die();
    return size;
  }

  /**
   Give birth to a new member of the populace
   **/
  void giveBirth() {
    //Give birth, take some energy away
    do {
      toAdd.add(new Creature(this));
    } while (random(1) < map(creatures.size(), 0, 30, 1, 0));//chance depending on pop size to add more children
    //Now determine if we live or not
    if (random(100) > energy) die();
  }

  /**
   Marks the creatures as dying, which means it
   fades out and then gets marked for removal
   */
  void die() {
    dead = true;
  }

  /**
   Render yourself
   **/
  void render() {
    //Quickly decrease opacity
    if (dead) opacity *= 0.9;
    //Finally remove us if we're hardly visible anymore
    if (opacity < 0.05) toRemove.add(this);
    //Save matrix position
    pushMatrix();
    //Now finally draw ourselves
    stroke(0, opacity * 255);
    strokeWeight(3);
    fill(c, 255 * opacity);
    circle(pos.x, pos.y, size);
    //And pop the matrix back to saved position
    popMatrix();
  }
}

/**
 Initializes the starting population
 **/
void creatureSetup() {
  for (int i = 0; i < STARTING_POPULATION; i++) {
    Creature c = new Creature();
    toAdd.add(c);
  }
  updateCreatures();
}

/**
 Handles list maintenance and updates all creatures
 **/
void updateCreatures() {
  //Add any creatures that are ready to be added
  if (toAdd.size() > 0) {
    for (Creature c : toAdd) creatures.add(c);
    toAdd.clear();
  }
  //Remove any creatures that were marked for deletion
  if (toRemove.size() > 0) {
    for (Creature c : toRemove) creatures.remove(c);
    toRemove.clear();
  }
  //Finally update all creatures
  avgSize = 0;
  for (Creature c : creatures) avgSize += c.update();
  avgSize /= creatures.size();
}
