// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

// Constants
float k = 1;
float kv = 0;
float mass = 1;
float gravity = 9.8;
float stringRestLength = 40;

// Basic Data Types
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Point that a string is attached to
class Ball {
    PVector position;
    PVector velocity;
    PVector acceleration;
    PVector force;
    
    public Ball(float x, float y) {
        position = new PVector(x, y);
        velocity = new PVector(0, 0);
        acceleration = new PVector(0, 0);
        force = new PVector(0, 0);
    }
    
    
    void updateAccelerationVelocityPosition(float dt, PVector forceBallBelow) {
        //acceleration.x = .5 * force.x / mass - .5 * forceBallBelow.x / mass;
        //acceleration.x = (force.x + forceBallBelow.x) / mass;
        //acceleration.y = gravity + .5 * force.y / mass - .5 * forceBallBelow.y / mass;
        acceleration.y = (force.y + forceBallBelow.y) / mass; 
        
        velocity.x += acceleration.x * dt;
        velocity.y += acceleration.y * dt;
        position.x += velocity.x * dt;
        position.y += velocity.y * dt;
        
        // TODO: handle floor collision
    }
    
    void updateForceXY(PVector stringTopPosition, PVector stringTopVelocity) {
        float dx = position.x - stringTopPosition.x;
        float dy = position.y - stringTopPosition.y;
        
        float stringLength = sqrt(dx * dx + dy * dy);
        
        float stringF = -k * (stringLength - stringRestLength);
        
        float dampFX = -kv * (velocity.x - stringTopVelocity.x);    
        float dampFY = -kv * (velocity.y - stringTopVelocity.y);
        
        force.x = stringF + dampFX;
        force.y = stringF + dampFY + gravity * mass;
        
        
        //println("force y: %s", force.y);
    }
}


/// A string that connects two balls
class ConnectingString {
    float length;
    
    /// First 
    Ball top;
    Ball bottom;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////

Ball top = new Ball(50, 40);
Ball bottom = new Ball(50, 100);

int ballCount = 3;

/// All balls in scene. The order they appear in the array is the order they'll be connected in.
Ball[] balls = new Ball[ballCount];

float time = 0;

void setup() {
    size(640, 360, P2D);

    noStroke();
  
    balls[0] = top;
    balls[1] = bottom;
    
    balls[2] = new Ball(50, 140);

}

void draw() {
    background(0);
    
    for (int t = 0; t < 10; t++) {
    // start by just updating the force for all balls except the top; the calculations that use the force are dependent on the ball below
    for(int i = 1; i < ballCount; i++) {
        balls[i].updateForceXY(balls[i - 1].position, balls[i - 1].velocity);
    }
    
    // update acceleration/velocity/position and actual drawing
    for(int i = 1; i < ballCount; i++) {
        if (i < ballCount - 1) {
            balls[i].updateAccelerationVelocityPosition(0.005, PVector.mult(balls[i + 1].force, -1));
        // last ball - don't want there to be any force from below as there isn't any    
        } else {
            balls[i].updateAccelerationVelocityPosition(0.005, new PVector(0, 0));
        }
    }
    }
    for(int i = 1; i < ballCount; i++) { 
        stroke(0, 255, 255);
        line(balls[i - 1].position.x, balls[i - 1].position.y, balls[i].position.x, balls[i].position.y);
        
        noStroke();
        fill(i * 80, i * 80, i * 80);
        circle(balls[i].position.x, balls[i].position.y, 20);
    }
    
    // top ball (so it's not underneath string)
    circle(balls[0].position.x, balls[0].position.y, 20);
    
    for(int i = 0; i < ballCount; i++) {
        //print("position x: ");
        //println(balls[i].position.x);
        //print("position y: ");
        //println(balls[i].position.y);
    }
}
