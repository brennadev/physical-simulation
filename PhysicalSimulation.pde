// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

import peasy.*;

// Constants
float k = 3;    // spring constant
float kv = 0.2;    // related to k; the dampening constant
float mass = 0.2;
float gravity = 9.8;
float stringRestLength = 30;
int floorLocation = 700;
float ballRadius = 10;
float density = 45;

// Drag values
boolean dragIsEnabled = false;    // true if drag should be shown; false if it shouldn't be shown; set this value before running program
final float dragCoefficient = 10;
final float airDensity = 1.2;     // from physics book at 20 degrees celsius and 1 atm
PVector velocityAir = new PVector(0, 0, -10);    // vair - get some values going in the z direction so that's shown too

// Rendering stuff
PeasyCam camera;
PImage texture;

// Cloth-Object Collision
PVector collidingSpherePosition = new PVector();
float sphereRadius = 20;


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
        acceleration.z = force.z / mass;
        
        velocity.x += acceleration.x * dt;
        velocity.y += acceleration.y * dt;
        velocity.z += acceleration.z * dt;
        
        position.x += velocity.x * dt;
        position.y += velocity.y * dt;
        position.z += velocity.z * dt;
        
        
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
        float dz = bottom.position.z - top.position.z;
        
        float stringLength = sqrt(dx * dx + dy * dy + dz * dz);
        
        float directionX = dx / stringLength;
        float directionY = dy / stringLength;
        float directionZ = dz / stringLength;
        
        float stringF = -k * (stringLength - stringRestLength);
        
        float dampFX = -kv * (bottom.velocity.x - top.velocity.x);
        float dampFY = -kv * (bottom.velocity.y - top.velocity.y);
        float dampFZ = -kv * (bottom.velocity.z - top.velocity.z);
        
        top.force.x += -0.5 * directionX * (stringF + dampFX);
        top.force.y += -0.5 * directionY * (stringF + dampFY);
        top.force.z += -0.5 * directionZ * (stringF + dampFZ);
        bottom.force.x += 0.5 * directionX * (stringF + dampFX);
        bottom.force.y += 0.5 * directionY * (stringF + dampFY);
        bottom.force.z += 0.5 * directionZ * (stringF + dampFZ);
    }
}


// Ball and thread data
//////////////////////////////////////////////////////////////////////////////////////////////////////////


int ballCountHorizontal = 10;
int ballCountVertical = 7;

Ball[][] balls = new Ball[ballCountHorizontal][ballCountVertical];

/// All strings that connect balls together - hold references to the needed balls
ConnectingString[][] verticalStrings = new ConnectingString[ballCountHorizontal][ballCountVertical - 1];
ConnectingString[][] horizontalStrings = new ConnectingString[ballCountHorizontal - 1][ballCountVertical];


// Drawing loop
//////////////////////////////////////////////////////////////////////////////////////////////////////////

void setup() {
    size(900, 700, P3D);


    camera = new PeasyCam(this, 0, 0, 0, 500);    // based on example usage in the PeasyCam documentation
    mass = density / (ballCountHorizontal * ballCountVertical);

    texture = loadImage("pattern.PNG");
    textureMode(NORMAL);    // I'm so used to working in normalized device coordinates
    noStroke();
  
    // initialize based on strings in the scene rather than balls in the scene (especially helpful once the horizontal threads go in)
    float startingY = -280;    // get the simulation out of the top left
    float startingX = -200;    // get the simulation out of the top left
    float ballSpacingHorizontal = stringRestLength;    // spacing between balls in x direction
    float ballSpacingVertical = stringRestLength;    // spacing between balls in y direction
    float horizontalOffset = stringRestLength / 10;    // each row is offset a little more so it's more of a diagonal grid
    float zOffset = 40;
    // horizontal spacing should be the rest length
    // vertical can be stretched but keep it at rest length to test
    // force calculations look correct
    
    
    // initialize balls
    for(int i = 0; i < ballCountHorizontal; i++) {
        for(int j = 0; j < ballCountVertical; j++) {
            balls[i][j] = new Ball(startingX + i * ballSpacingHorizontal + j * horizontalOffset, startingY + j * (ballSpacingVertical + 10));
            balls[i][j].position.z = j * zOffset;
            println(balls[i][j].position);
        }
    }
    
    // initialize strings in horizontal direction
    for(int i = 0; i < ballCountHorizontal - 1; i++) {
        for(int j = 0; j < ballCountVertical; j++) {
            horizontalStrings[i][j] = new ConnectingString(balls[i][j], balls[i + 1][j]);
            
        }
    }
    
    // initialize strings in vertical direction
    for(int i = 0; i < ballCountHorizontal; i++) {
        for(int j = 0; j < ballCountVertical - 1; j++) {
            verticalStrings[i][j] = new ConnectingString(balls[i][j], balls[i][j + 1]);
        }
    }
}

void draw() {
    background(100);
    
    // this loop here so it moves faster without introducing instability
    for (int t = 0; t < 3000; t++) {
        
        // update the forces for all balls before updating acceleration/velocity/position
        for(int i = 0; i < ballCountHorizontal; i++) {
            // don't want any force values from before, and multiple strings update the force, so that's why this can't be in the ConnectingString updateForces method
            for(int j = 0; j < ballCountVertical; j++) {
                balls[i][j].force.x = 0;
                balls[i][j].force.y = 0;
                balls[i][j].force.z = 0;
            }
        }
    
    
        // the regular force calculations from strings
        for(int i = 0; i < ballCountHorizontal - 1; i++) {
            for(int j = 0; j < ballCountVertical; j++) {
                horizontalStrings[i][j].updateForces();
            }
        }
        
        for(int i = 0; i < ballCountHorizontal; i++) {
            for(int j = 0; j < ballCountVertical - 1; j++) {
                verticalStrings[i][j].updateForces();
            }
        }
        
        // drag force
        if (dragIsEnabled) {
            // go through the number of quads in the cloth
            for(int j = 0; j < ballCountVertical - 1; j++) {
                for(int i = 0; i < ballCountHorizontal - 1; i++) {
                    // 2 triangles per quad //<>//
                    
                    println("i: " + i); //<>//
                    println("j: " + j);
                    PVector leftTriangle = getDrag(balls[i][j], balls[i][j + 1], balls[i + 1][j + 1]);
                    PVector rightTriangle = getDrag(balls[i][j], balls[i + 1][j + 1], balls[i + 1][j]);
                    println("leftTriangle: " + leftTriangle);
                    
                    PVector leftTriangleSinglePointForce = leftTriangle.div(3);
                    PVector rightTriangleSinglePointForce = rightTriangle.div(3);
                    
                    println("leftTriangleSinglePointForce: " + leftTriangleSinglePointForce);
                    println("rightTriangleSinglePointForce: " + rightTriangleSinglePointForce);
                    
                    println("top left force before: " + balls[i][j].force); //<>//
                    balls[i][j].force.add(leftTriangleSinglePointForce).add(rightTriangleSinglePointForce);
                    println("top left force after: " + balls[i][j].force);
                    balls[i][j + 1].force.add(leftTriangleSinglePointForce);
                    balls[i + 1][j + 1].force.add(leftTriangleSinglePointForce).add(rightTriangleSinglePointForce);
                    balls[i + 1][j].force.add(rightTriangleSinglePointForce);
                }
            }
        }
        
    
        // update acceleration/velocity/position - only want to update the non-anchor balls since the anchor balls shouldn't move
        for(int i = 0; i < ballCountHorizontal; i++) {
            for(int j = 1; j < ballCountVertical; j++) {
                // only want the gravity applied to a given non-anchor ball once
                balls[i][j].force.y += gravity * mass;
                balls[i][j].updateAccelerationVelocityPosition(0.00001);
            }
        }
        
        // collision with sphere
        for(int i = 0; i < ballCountHorizontal; i++) {
            for(int j = 0; j < ballCountVertical; j++) {
                float distance = PVector.dist(balls[i][j].position, collidingSpherePosition);
                
                if (distance < sphereRadius + 0.09) {
                    PVector sphereNormal = PVector.mult(PVector.sub(collidingSpherePosition, balls[i][j].position), -1);
                    sphereNormal.normalize();
                    PVector bounce = PVector.mult(sphereNormal, PVector.dot(balls[i][j].velocity, sphereNormal));
                    balls[i][j].velocity.sub(PVector.mult(bounce, 1.5));
                    balls[i][j].position.add(PVector.mult(sphereNormal, .1 + sphereRadius - distance));
                }
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    // could probably use this for a sphere to intersect with
   /* translate(-300, 0, -300);
    box(600, 50, 600);
    translate(300, 0, 300);*/
    
    /*beginShape();
    vertex(-300, 0, -300);
    vertex(-300, 0, 300);
    vertex(300, 0, 300);
    vertex(300, 0, -300);
    endShape();*/
    
    fill(0, 210, 255);
    translate(collidingSpherePosition.x, collidingSpherePosition.y, collidingSpherePosition.z);
    sphere(sphereRadius);
    translate(-1 * collidingSpherePosition.x, -1 * collidingSpherePosition.y, -1 * collidingSpherePosition.z);

    // textured drawing of cloth
    for(int i = 0; i < ballCountHorizontal - 1; i++) {
        for(int j = 0; j < ballCountVertical - 1; j++) {
            beginShape();
            texture(texture);
            vertex(balls[i][j].position.x, balls[i][j].position.y, 0, 0);
            vertex(balls[i][j + 1].position.x, balls[i][j + 1].position.y, 0, 1);
            vertex(balls[i + 1][j + 1].position.x, balls[i + 1][j + 1].position.y, 1, 1);
            vertex(balls[i + 1][j].position.x, balls[i + 1][j].position.y, 1, 0);
            endShape();
        }
    }
}


/// Get drag force (f aero)
PVector getDrag(Ball corner1, Ball corner2, Ball corner3) {
    PVector v = corner1.velocity.add(corner2.velocity.add(corner3.velocity)).div(3).sub(velocityAir);
    PVector n = new PVector();

    PVector.cross(corner2.position.sub(corner1.position), corner3.position.sub(corner1.position), n);
    
    return (n.mult(-0.5 * airDensity * dragCoefficient)).mult(v.mag() * v.dot(n) / (2 * n.mag()));
}


void keyPressed() {
    switch (keyCode) {
        case LEFT:
        collidingSpherePosition.x -= 20;
        break;
        
        case RIGHT:
        collidingSpherePosition.x += 20;
        break;
        
        case SHIFT:
        break;
    }
}
