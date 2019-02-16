// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

// Constants
float k = 10;
float kv = 10;
float mass = 10;
float gravity = 9.8;
float stringRestLength = 10;

// Basic Data Types
//////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Point that a string is attached to
class Ball {
    PVector position;
    PVector velocity;
    PVector acceleration;
    
    public Ball(float x, float y) {
        position = new PVector(x, y);
        velocity = new PVector(0, 0);
        acceleration = new PVector(0, 0);
    }
    
    void update(float dt, PVector stringTop) {
        float dx = position.x - stringTop.x;
        float dy = position.y - stringTop.y;
        
        float stringLength = sqrt(dx * dx + dy * dy);
        
        float stringF = -k * (stringLength - stringRestLength);
        
        float dirX = dx / stringLength;
        float dirY = dy / stringLength;
        
        float dampFX = -kv * (velocity.x - 0);    // null pointer exception here
        float dampFY = -kv * (velocity.y - 0);
        
        velocity.x += stringF * dirX * dt + dampFX * dt;
        velocity.y += stringF * dirY * dt + dampFY * dt;
        
        position.x += velocity.x * dt;
        position.y += velocity.y * dt;
        velocity.y += gravity * dt;
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
Ball bottom = new Ball(50, 80);

int ballCount = 2;

/// All balls in scene. The order they appear in the array is the order they'll be connected in.
Ball[] balls = new Ball[ballCount];

float time = 0;

void setup() {
    size(640, 360, P2D);

    noStroke();
    
    //top.position = new PVector(50, 40);
    //bottom.position = new PVector(50, 80);
  
    balls[0] = top;
    balls[1] = bottom;
}

void draw() {
    background(0);
    for(int i = 0; i < 2; i++) {
        
        
        // only draw a line if we're not at the bottom ball
        if (i < ballCount - 1) {
            
            balls[i + 1].update(0.03, balls[i].position);
            
            stroke(0, 255, 255);
            line(balls[i].position.x, balls[i].position.y, balls[i + 1].position.x, balls[i + 1].position.y);
        }
        
        circle(balls[i].position.x, balls[i].position.y, 20);
    }
     //circle(50, 40, 20);
     
     time += 0.2;
}
