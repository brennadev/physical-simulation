// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

// Constants
float k = 3;    // spring constant
float kv = 0.3;    // related to k; the dampening constant
float mass = 0.5;
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
        if (position.y > floorLocation - ballRadius) {
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
        
        float dampFX = 0;//-kv * (bottom.velocity.x - top.velocity.x);
        float dampFY = 0;//-kv * (bottom.velocity.y - top.velocity.y);
        
        top.force.x += -0.5 * directionX * (stringF + dampFX);
        top.force.y += -0.5 * directionY * (stringF + dampFY);
        bottom.force.x += 0.5 * directionX * (stringF + dampFX);
        bottom.force.y += 0.5 * directionY * (stringF + dampFY);
    }
}


// Ball and thread data
//////////////////////////////////////////////////////////////////////////////////////////////////////////


int ballCountHorizontal = 2;
int ballCountVertical = 2;

Ball[][] balls = new Ball[ballCountHorizontal][ballCountVertical];

/// All strings that connect balls together - hold references to the needed balls
ConnectingString[][] verticalStrings = new ConnectingString[ballCountHorizontal - 1][ballCountVertical - 1];
ConnectingString[][] horizontalStrings = new ConnectingString[ballCountHorizontal - 1][ballCountVertical - 1];


// Drawing loop
//////////////////////////////////////////////////////////////////////////////////////////////////////////

void setup() {
    size(640, 360, P2D);

    noStroke();
  
    // initialize based on strings in the scene rather than balls in the scene (especially helpful once the horizontal threads go in)
    float startingY = 30;    // get the simulation out of the top left
    float startingX = 100;    // get the simulation out of the top left
    float ballSpacingHorizontal = stringRestLength;    // spacing between balls in x direction
    float ballSpacingVertical = 30;    // spacing between balls in y direction
    float horizontalOffset = 30;    // each row is offset a little more so it's more of a diagonal grid
    // horizontal spacing should be the rest length
    // vertical can be stretched but keep it at rest length to test
    // force calculations look correct
    
    // initialize balls
    for(int i = 0; i < ballCountHorizontal; i++) {
        for(int j = 0; j < ballCountVertical; j++) {
                balls[i][j] = new Ball(startingX + i * ballSpacingHorizontal /*+ j * horizontalOffset*/, startingY + j * ballSpacingVertical);
        }
    }
    
    // initialize strings in both directions
    for(int i = 0; i < ballCountHorizontal - 1; i++) {
        for(int j = 0; j < ballCountVertical - 1; j++) {
            horizontalStrings[i][j] = new ConnectingString(balls[i][j], balls[i][j + 1]);
            verticalStrings[i][j] = new ConnectingString(balls[i][j], balls[i + 1][j]);
        }
    }
}

void draw() {
    background(0);
    
    // this loop here so it moves faster without introducing instability
    //for (int t = 0; t < 10; t++) {
        
        // update the forces for all balls before updating acceleration/velocity/position
        for(int i = 0; i < ballCountHorizontal; i++) {
            // don't want any force values from before, and multiple strings update the force, so that's why this can't be in the ConnectingString updateForces method
            for(int j = 0; j < ballCountVertical; j++) {
                balls[i][j].force.x = 0;
                balls[i][j].force.y = 0;
            }
        }
    
    
        // the regular force calculations
        for(int i = 0; i < ballCountHorizontal - 1; i++) {
            for(int j = 0; j < ballCountVertical - 1; j++) {
                verticalStrings[i][j].updateForces();
                horizontalStrings[i][j].updateForces();
            }
        }
        
    
        // update acceleration/velocity/position - only want to update the non-anchor balls since the anchor balls shouldn't move
        for(int i = 0; i < ballCountHorizontal; i++) {
            for(int j = 1; j < ballCountVertical; j++) {
                // only want the gravity applied to a given non-anchor ball once
                balls[i][j].force.y += gravity * mass;
        
        // timestep was .005
                if (j < ballCountVertical - 1) {
                balls[i][j].updateAccelerationVelocityPosition(0.001);
                // last ball - don't want there to be any force from below as there isn't any    
                } else {
                    balls[i][j].updateAccelerationVelocityPosition(0.001);
                }
            }
        }
    //}
    
    println("x bottom: " + balls[0][1].position.x);
    println("y bottom: " + balls[0][1].position.y);
    
    // drawing
    
    stroke(0, 255, 255);
    
    
    for(int i = 0; i < ballCountHorizontal - 1; i++) {
        for(int j = 0; j < ballCountVertical; j++) {
            line(balls[i][j].position.x, balls[i][j].position.y, balls[i + 1][j].position.x, balls[i + 1][j].position.y);
        }
    }
    
    
    for(int i = 0; i < ballCountHorizontal; i++) { 
        for(int j = 1; j < ballCountVertical; j++) { 
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
