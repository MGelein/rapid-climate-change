/**
 * This sketch is part of the final assignment for the course Scientific Narration & Visualization
 * of Media Technology MSc, Leiden University, taught by Prof. Dr. B. Haring. 
 * 
 * This Arduino code reads two inputs (a potentiometer and a togglebutton) and sends these
 * values over the Serial line to the processing sketch. In this sketch the potmeter controls
 * the ambient temperature, while the toggle controls a population reset.
 * 
 * This code is licensed under MIT
 * @author	Mees Gelein
 * @version	0.1.3
 * @license MIT
**/


/**
 * Simple sketch that outputs the values of a potmeter and a togglebutton
 * over the Serial monitor
 */
void setup() {
  //Begin the serial communication at a high baud rate
  Serial.begin(9600);

  //Set the pinModes
  pinMode(13, OUTPUT);
  digitalWrite(13, HIGH);//Pin 13 is used as source current for the toggle
}

void loop() {
  //Read the potmeter
  int pot = analogRead(A0);
  int button = digitalRead(12);
  Serial.println(String(pot) + ":" + String(button) + "#");
  //Wait for around 10 ms
  delay(10);
}
