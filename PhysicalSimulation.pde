// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

// Constants
float k = 1;
float kv = 0.1;
float mass = 1;
float gravity = 9.8;
float stringRestLength = 30;
int floorLocation = 360;
float ballRadius = 10;

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
    
    
    void updateAccelerationVelocityPosition(float dt) {
        acceleration.x = force.x / mass;
        acceleration.y = force.y / mass;
        
        velocity.x += acceleration.x * dt;
        velocity.y += acceleration.y * dt;
        position.x += velocity.x * dt;
        position.y += velocity.y * dt;
        
        // TODO: handle floor collision
        if (position.y > floorLocation) {
            velocity.y *= -0.9;
            position.y = floorLocation - ballRadius;
        }
    }
}


/// A string that connects two balls
class ConnectingString {
    /// First ball the string is attached to
    Ball top;
    
    /// Second ball the string is attached to
    Ball bottom;
    
    public ConnectingString(Ball top, Ball bottom) {
        this.top = top;
        this.bottom = bottom;
    }
    
    /// Update the forces for the 2 balls attached to the string
    void updateForces() {
        float dx = bottom.position.x - top.position.x;
        float dy = bottom.position.y - top.position.y;
        
        float stringLength = sqrt(dx * dx + dy * dy);
        
        float directionX = dx / stringLength;
        float directionY = dy / stringLength;
        
        float stringF = -k * (stringLength - stringRestLength);
        
        float dampFX = -kv * (bottom.velocity.x - top.velocity.x);
        float dampFY = -kv * (bottom.velocity.y - top.velocity.y);
        
        top.force.x += -0.5 * directionX * (stringF + dampFX);
        top.force.y += -0.5 * directionY * (stringF + dampFY);
        bottom.force.x += 0.5 * directionX * (stringF + dampFX);
        bottom.force.y += 0.5 * directionY * (stringF + dampFY);
    }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////

int ballCount = 8;
int stringCount = ballCount - 1;

/// All balls in scene. The order they appear in the array is the order they'll be connected in. 
/// Even though the strings are stored, some calculations are easier to do per-ball rather than per-string
Ball[] balls = new Ball[ballCount];


/// All strings that connect balls together - hold references to the needed balls
ConnectingString[] strings = new ConnectingString[stringCount];


void setup() {
    size(640, 360, P2D);

    noStroke();
  
    // initialize based on strings in the scene rather than balls in the scene (especially helpful once the horizontal threads go in)
    float startingY = 30;
    float startingX = 100;
    float ballSpacingHorizontal = 70;
    float ballSpacingVertical = 40;
    
    
    // values used in string initialization loop
    Ball top = new Ball(startingX, startingY);
    Ball bottom;
    balls[0] = top;
    
    for (int i = 0; i < stringCount; i++) {
        bottom = new Ball(ballSpacingHorizontal + (i + 1) + startingX, ballSpacingVertical * (i + 1) + startingY);
        balls[i + 1] = bottom;
        strings[i] = new ConnectingString(top, bottom);
        top = bottom;
    }
}

void draw() {
    background(0);
    
    for (int t = 0; t < 10; t++) {
        
        for(int i = 0; i < ballCount; i++) {
            balls[i].force.x = 0;
            balls[i].force.y = 0;
        }
    
    for(int i = 0; i < stringCount; i++) {
        strings[i].updateForces();
    }
    
    // update acceleration/velocity/position - only want to update the non-anchor balls since the anchor balls shouldn't move
    for(int i = 1; i < ballCount; i++) {
        // only want the gravity applied to a given non-anchor ball once
        balls[i].force.y += gravity * mass;
        
        if (i < ballCount - 1) {
            balls[i].updateAccelerationVelocityPosition(0.005);
        // last ball - don't want there to be any force from below as there isn't any    
        } else {
            balls[i].updateAccelerationVelocityPosition(0.005);
        }
    }
    }
    for(int i = 1; i < ballCount; i++) { 
        stroke(0, 255, 255);
        line(balls[i - 1].position.x, balls[i - 1].position.y, balls[i].position.x, balls[i].position.y);
        
        noStroke();
        fill(i * 50, i * 50, i * 50);
        circle(balls[i].position.x, balls[i].position.y, ballRadius * 2);
    }
    
    // top ball (so it's not underneath string)
    circle(balls[0].position.x, balls[0].position.y, ballRadius * 2);
    
    // TODO: remove print statements
    /*for(int i = 0; i < ballCount; i++) {
        println(i + ":");
        print("position x: ");
        println(balls[i].position.x);
        print("position y: ");
        println(balls[i].position.y);
        print("force y: ");
        println(balls[i].force.y);
    }
    
    // put in here just in case there was an issue with the references, but there doesn't appear to be any
    println("strings");
    for(int i = 0; i < stringCount; i++) {
        println("string " + i + ":");
        
        print("position x top ball: ");
        println(strings[i].top.position.x);
        print("position y top ball: ");
        println(strings[i].top.position.y);
        
        print("position x bottom ball: ");
        println(strings[i].bottom.position.x);
        print("position y bottom ball: ");
        println(strings[i].bottom.position.y);
    }*/
}
