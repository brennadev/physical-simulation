// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

// Constants
float k = 1;
float kv = 0.1;
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
    
    
    void updateAccelerationVelocityPosition(float dt) {
        //acceleration.x = .5 * force.x / mass - .5 * forceBallBelow.x / mass;
        //acceleration.x = (force.x + forceBallBelow.x) / mass;
        //acceleration.y = gravity + .5 * force.y / mass - .5 * forceBallBelow.y / mass;
        //acceleration.y = (force.y + forceBallBelow.y) / mass; 
        
        
        // TODO: set acceleration in x direction
        
        acceleration.y = force.y / mass;
        
        velocity.x += acceleration.x * dt;
        velocity.y += acceleration.y * dt;
        position.x += velocity.x * dt;
        position.y += velocity.y * dt;
        
        // TODO: handle floor collision
    }
    
    // TODO: remove eventually
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
        
        println("dy: " + dy);
        println("directionX: " + directionX);
        println("directionY: " + directionY);
        
        // lost the direction here - direction is independent of the magnitude; multiply the forces by the sign of dy
        
        // putting in dy directly will work for when you're going in the y direction only
        float stringF = -k * (stringLength - stringRestLength);
        
        float dampFX = -kv * (bottom.velocity.x - top.velocity.x);
        float dampFY = -kv * (bottom.velocity.y - top.velocity.y);
        
        top.force.x += -0.5 * directionX * (stringF + dampFX);
        top.force.y += -0.5 * directionY * (stringF + dampFY);
        bottom.force.x += 0.5 * directionX * (stringF + dampFX);
        bottom.force.y += 0.5 * directionY * (stringF + dampFY);
        
        bottom.force.y += gravity * mass;
        
        // TODO: not sure if gravity calculation is correct - will need to move out of here and into draw at some point
    }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////

int ballCount = 5;
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
    float startingX = 50;
    float ballSpacingVertical = 50;
    
    
    // values used in string initialization loop
    Ball top = new Ball(startingX, startingY);
    Ball bottom;
    balls[0] = top;
    
    for (int i = 0; i < stringCount; i++) {
        bottom = new Ball(startingX, ballSpacingVertical * (i + 1) + startingY);
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
    
    // update acceleration/velocity/position and actual drawing
    for(int i = 1; i < ballCount; i++) {
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
        circle(balls[i].position.x, balls[i].position.y, 20);
    }
    
    // top ball (so it's not underneath string)
    circle(balls[0].position.x, balls[0].position.y, 20);
    
    for(int i = 0; i < ballCount; i++) {
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
    }
}
