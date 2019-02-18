// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

// Constants
float k = 100;
float kv = 20;
float mass = 10;
float gravity = 100;
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
    
    void update(float dt, PVector stringTop, PVector velocityTop) {
        float dx = position.x - stringTop.x;
        float dy = position.y - stringTop.y;
        
        float stringLength = sqrt(dx * dx + dy * dy);
        
        float stringF = -k * (stringLength - stringRestLength);
        
        float dirX = dx / stringLength;
        float dirY = dy / stringLength;
        
        float dampFX = -kv * (velocity.x - velocityTop.x);    
        float dampFY = -kv * (velocity.y - velocityTop.y);
        
        velocity.x += stringF * dirX * dt + dampFX * dt;
        velocity.y += stringF * dirY * dt + dampFY * dt;
        velocity.y += gravity * dt;
        
        position.x += velocity.x * dt;
        System.out.println(position.x);
        position.y += velocity.y * dt;
    }
    
    
    void updateForceXY(PVector stringTopPosition, PVector stringTopVelocity) {
        float dx = position.x - stringTopPosition.x;
        float dy = position.y - stringTopPosition.y;
        
        float stringLength = sqrt(dx * dx + dy * dy);
        
        float stringF = -k * (stringLength - stringRestLength);
        
        float dampFX = -kv * (velocity.x - stringTopVelocity.x);    
        float dampFY = -kv * (velocity.y - stringTopVelocity.y);
        
        force.x = stringF + dampFX;
        force.y = stringF + dampFY;
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
Ball bottom = new Ball(50, 150);

int ballCount = 3;

/// All balls in scene. The order they appear in the array is the order they'll be connected in.
Ball[] balls = new Ball[ballCount];

float time = 0;

void setup() {
    size(640, 360, P2D);

    noStroke();
  
    balls[0] = top;
    balls[1] = bottom;
    //balls[1].velocity.x = 200;
    //balls[1].acceleration.x = 2;
    
    balls[2] = new Ball(50, 180);
    
    balls[1].velocity.y = -5;
    balls[2].velocity.y = -5;
    
    
}

void draw() {
    background(0);
    
    // start by just updating the force for all balls except the top; the calculations that use the force are dependent on the ball below
    for(int i = 1; i < ballCount; i++) {
        balls[i].updateForceXY(balls[i - 1].position, balls[i - 1].velocity);
    }
    
    // then do the updates for position/velocity/acceleration
    for(int i = 0; i < ballCount; i++) {
        
        
        // only draw a line if we're not at the bottom ball
        if (i < ballCount - 1) {
            
            // updating the ball that's one down with the info from the current ball
            balls[i + 1].update(0.03, balls[i].position, balls[i].velocity);
            
            stroke(0, 255, 255);
            line(balls[i].position.x, balls[i].position.y, balls[i + 1].position.x, balls[i + 1].position.y);
        }
        
        fill(i * 80, i * 80, i * 80);
        circle(balls[i].position.x, balls[i].position.y, 20);
    }

     
     time += 0.2;
}
