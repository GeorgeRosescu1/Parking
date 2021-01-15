#include <SoftwareSerial.h>

SoftwareSerial BLE(2, 3);

const int trigPin = 11;
const int echoPin = 12;

float duration, distance;
float oldDistance = 0.0;


void setup() {
  BLE.begin(9600);
  Serial.begin(9600);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(13, OUTPUT);
}

void loop() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  duration = pulseIn(echoPin, HIGH);
  distance = (duration * .0343) / 2;

  if (abs(distance - oldDistance) >= 5) {
    Serial.println(distance);
    oldDistance = distance;
    if (oldDistance <= 20.0) {
      delay(100);
      if(BLE.available()) {
        BLE.write('t');
      }
    } else {
      delay(100);
      if(BLE.available()) {
        BLE.write('f');
      }
    }
  }
}
