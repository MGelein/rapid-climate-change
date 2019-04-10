/**
This code was created for the final assignment of the Scientific Narration & Visualization
course of Media Technology MSc. of Leiden University, taught by Prof. Dr. B. Haring.

The processing part of this project is the simulation of a 'population' of creatures, which
are represented by circles. The circles differ in size, and inherit their size (with a slight
mutation) from their parents. These creatures evolve according to their ambient temperature.

This code and the entirety of this project is licensed under the MIT license.

@author  Mees Gelein
@version  1.0.13
@license  MIT
**/

import processing.serial.*;

//Some hard coded parameters
final int STARTING_POPULATION = 20;
final int minTemp = 0;
final int maxTemp = 50;

//The potentiometer value
int potValue = 512;
int buttonValue = 0;
int oldButtonValue = 0;

//The ambient temperature
float ambientTemp = (minTemp + maxTemp) / 2;

//The three background images used to show the difference in temperature
PImage arctic;
PImage desert;
PImage temperate;

//The serial used for communication with the Arduino
Serial serial;
String buffer = "";

/**
 One time setup
 **/
void setup() {
  //Set the window size
  size(1280, 720);
  colorMode(HSB);
  
  //Load the three background images
  arctic = loadImage("arctic.jpg");
  desert = loadImage("desert.jpg");
  temperate = loadImage("temperate.jpg");

  //Set the center of the screen
  center.x = width / 2;
  center.y = height / 2;

  //Load a custom font
  textFont(createFont("LemonMilk.otf", 24));

  //Create the serial port at the correct baud rate
  serial = new Serial(this, Serial.list()[0], 9600);
}

/**
 Runs at the framerate
 **/
void draw() {
  //Draw a color dependent background color
  float hue = map(ambientTemp, minTemp, maxTemp, 150, 0);
  background(hue, 30, 255);
  //Draw the image overlay for the background
  imageOverlay(hue);

  //Update and render all creatures
  updateCreatures();

  //Draw the UI overlay
  tempOverlay(hue);

  //Handle the serial communication
  while (serial.available() > 0) {//As long as there are lines to read
    String line = serial.readString();
    if (line != null) {
      buffer += line;
      parseSerial();
    }
  }
  
  //If the button was flipped (the toggle)
  if(buttonValue != oldButtonValue){
    creatureSetup();
    oldButtonValue = buttonValue;
  }
  
  //Get the ambient temp from the potValue
  ambientTemp = map(potValue, 0, 1023, minTemp, maxTemp);
}

/**
 Parses a single line of serial data
 **/
void parseSerial() {
  String[] lines = buffer.replaceAll("\n","").split("#");
  for(int i = 0; i < lines.length - 1; i++){
    String[] parts = lines[i].split(":");
    if(parts.length > 1){//Only read messages with enough parts
      potValue = parseInt(parts[0].trim());
      buttonValue = parseInt(parts[1].substring(0, 1));
    }
  }
  buffer = lines[lines.length - 1];
}

/**
 Draw the temperature overlay
 **/
void tempOverlay(float h) {
  //Shadow
  noStroke();
  fill(0, 120);
  rect(25, height - 45, width - 40, 40);
  //Back bar
  stroke(0);
  fill(h, 0, 190);
  rect(20, height - 50, width - 40, 40);

  //Now draw the temp bar
  noStroke();
  fill(h, 200, 200);
  float endPos = constrain(map(ambientTemp, minTemp, maxTemp, 0, 1), 0, 1);
  float xPos = 22;
  float yPos = height - 48;
  float right = xPos + endPos * (width - 64) + 10;
  float h2 = 36;
  rect(xPos, yPos, right, h2);
  stroke(h, 255, 255);
  line(xPos, yPos + h2, xPos, yPos);
  line(xPos, yPos, right + xPos, yPos);
  stroke(h, 200, 100);
  line(right + xPos, yPos, right + xPos, yPos + h2);
  line(right + xPos, yPos + h2, xPos, yPos + h2);

  //Draw the temp overlay, first shadow
  noStroke();
  fill(0, 120);
  rect(width / 2 - 75, height - 75, 160, 60);
  stroke(0);
  fill(h, 0, 190);
  rect(width / 2 - 80, height - 80, 160, 60);
  fill(0);
  String tempLabel = (int) ambientTemp + "°C";
  float hw = textWidth(tempLabel) / 2;
  text(tempLabel, width / 2 - hw, height - 30);
}

/**
 Reseeds the population on a space press
 **/
void keyPressed() {
  if (keyCode == 32) creatureSetup();
}

/**
 Draw the image overlay on top of the hue background
 **/
void imageOverlay(float hue) {
  //If lower than 25, use first two images, else use other two
  if (ambientTemp < 25) {
    //Calc opacity for the ambient Temp
    float ratio = (25 - ambientTemp) / 25;
    tint(hue, 255, 255, 120 * ratio);
    image(arctic, 0, 0, width, height);
    tint(hue, 255, 255, 120 * (1 - ratio));
    image(temperate, 0, 0, width, height);
  } else {
    //Calc opacity for the ambient Temp
    float ratio = abs((25 - ambientTemp)) / 25;
    tint(hue, 255, 255, 120 * ratio);
    image(desert, 0, 0, width, height);
    tint(hue, 255, 255, 120 * (1 - ratio));
    image(temperate, 0, 0, width, height);
  }
}
