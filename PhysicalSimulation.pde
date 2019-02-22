// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

// Constants
float k = 2;
float kv = 0.2;
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
        
        // floor collision
        if (position.y > floorLocation) {
            velocity.y *= -0.9;
            position.y = floorLocation - ballRadius;
        }
    }
}


/// A string that connects two balls - holds references to the 2 balls it's connected to
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


// Ball and thread data
//////////////////////////////////////////////////////////////////////////////////////////////////////////

/// Number of balls per thread
int ballCount = 6;

/// Number of vertical threads for the cloth
int threadCount = 5;
/// How many strings connect in a single vertical thread
int stringCountSingleThread = ballCount - 1;
/// Total number of strings connecting balls in the cloth
int stringCountTotal = (ballCount - 1) * threadCount;

/// All balls in scene. The order they appear in the array is the order they'll be connected in. 
/// Even though the strings are stored, some calculations are easier to do per-ball rather than per-string
Ball[][] balls = new Ball[threadCount][ballCount];

/// All strings that connect balls together - hold references to the needed balls
ConnectingString[] strings = new ConnectingString[stringCountTotal];


// Drawing loop
//////////////////////////////////////////////////////////////////////////////////////////////////////////

void setup() {
    size(640, 360, P2D);

    noStroke();
  
    // initialize based on strings in the scene rather than balls in the scene (especially helpful once the horizontal threads go in)
    float startingY = 30;
    float startingX = 100;
    float ballSpacingHorizontalSingleString = 70;
    float ballSpacingVertical = 40;
    float ballSpacingHorizontalBetweenStrings = 50;
    
    // values used in string initialization loop
    for(int i = 0; i < threadCount; i++) {
        
        float horizontalStart = ballSpacingHorizontalBetweenStrings * (i + 1);
        Ball top = new Ball(startingX + horizontalStart, startingY);
        Ball bottom;
        balls[i][0] = top;
    
        // set up the balls to each string
        for (int j = 0; j < stringCountSingleThread; j++) {
            bottom = new Ball(horizontalStart + ballSpacingHorizontalSingleString + (j + 1) + startingX, ballSpacingVertical * (j + 1) + startingY);
            println("j + 1: " + j + 1);
            balls[i][j + 1] = bottom;    // out of bounds exception 5 on this line
            strings[i * stringCountSingleThread + j] = new ConnectingString(top, bottom);
            top = bottom;
        }
    }
}

void draw() {
    background(0);
    
    // this loop here so it moves faster without introducing instability
    for (int t = 0; t < 10; t++) {
        
        // update the forces for all balls before updating acceleration/velocity/position
        for(int i = 0; i < threadCount; i++) {
            // don't want any force values from before, and multiple strings update the force, so that's why this can't be in the ConnectingString updateForces method
            for(int j = 0; j < ballCount; j++) {
                balls[i][j].force.x = 0;
                balls[i][j].force.y = 0;
            }
        }
    
        // the regular force calculations
        for(int i = 0; i < stringCountTotal; i++) {
            strings[i].updateForces();
        }
    
        // update acceleration/velocity/position - only want to update the non-anchor balls since the anchor balls shouldn't move
        for(int i = 0; i < threadCount; i++) {
            for(int j = 1; j < ballCount; j++) {
                // only want the gravity applied to a given non-anchor ball once
                balls[i][j].force.y += gravity * mass;
        
                if (j < ballCount - 1) {
                balls[i][j].updateAccelerationVelocityPosition(0.005);
                // last ball - don't want there to be any force from below as there isn't any    
                } else {
                    balls[i][j].updateAccelerationVelocityPosition(0.005);
                }
            }
        }
    }
    
    // drawing
    for(int i = 0; i < threadCount; i++) {
        for(int j = 1; j < ballCount; j++) { 
            stroke(0, 255, 255);
            line(balls[i][j - 1].position.x, balls[i][j - 1].position.y, balls[i][j].position.x, balls[i][j].position.y);
        
            noStroke();
            fill(j * 50, j * 50, j * 50);
            circle(balls[i][j].position.x, balls[i][j].position.y, ballRadius * 2);
        }
    
        // top ball (so it's not underneath string)
        circle(balls[i][0].position.x, balls[i][0].position.y, ballRadius * 2);
    }
}
