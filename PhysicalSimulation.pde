// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only.

import peasy.*;

// Constants
float k = 20;    // spring constant
float kv = 2;    // related to k; the dampening constant
float mass = 1;
float gravity = 3;
float stringRestLength = 10;
int floorLocation = 700;
float density = 45;

// Drag values
boolean dragIsEnabled = false;    // true if drag should be shown; false if it shouldn't be shown; set this value before running program
final float dragCoefficient = 10;
final float airDensity = 1.2;     // from physics book at 20 degrees celsius and 1 atm
PVector velocityAir = new PVector(0, 0, -40);    // vair - get some values going in the z direction so that's shown too

// Rendering stuff
PeasyCam camera;
PImage texture;

// Cloth-Object Collision
boolean collisionIsEnabled = false;
PVector collidingSpherePosition = new PVector();
float sphereRadius = 50;
boolean shiftKeyIsDown = false;    // for user interaction with the sphere's position


// Ball and thread data
//////////////////////////////////////////////////////////////////////////////////////////////////////////


int ballCountHorizontal = 10;
int ballCountVertical = 15;

Ball[][] balls = new Ball[ballCountHorizontal][ballCountVertical];

/// All strings that connect balls together - hold references to the needed balls
ConnectingString[][] verticalStrings = new ConnectingString[ballCountHorizontal][ballCountVertical - 1];
ConnectingString[][] horizontalStrings = new ConnectingString[ballCountHorizontal - 1][ballCountVertical];


// Drawing loop
//////////////////////////////////////////////////////////////////////////////////////////////////////////

void setup() {
    size(900, 700, P3D);

    camera = new PeasyCam(this, 0, 0, 0, 500);    // based on example usage in the PeasyCam documentation
    //mass = density / (ballCountHorizontal * ballCountVertical);
    mass = 1;

    texture = loadImage("pattern.PNG");
    textureMode(NORMAL);    // I'm so used to working in normalized device coordinates
    noStroke();
  
    // initialize based on strings in the scene rather than balls in the scene (especially helpful once the horizontal threads go in)
    float startingY = -100;    // get the simulation out of the top left
    float startingX = -75;    // get the simulation out of the top left
    float ballSpacingHorizontal = stringRestLength;    // spacing between balls in x direction
    float ballSpacingVertical = stringRestLength;    // spacing between balls in y direction
    float zOffset = stringRestLength / 3;
    
    
    // initialize balls
    for(int i = 0; i < ballCountHorizontal; i++) {
        for(int j = 0; j < ballCountVertical; j++) {
            balls[i][j] = new Ball(startingX + i * ballSpacingHorizontal /*+ j * horizontalOffset*/, startingY + j * ballSpacingVertical);
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
    println("frame rate: " + frameRate);
    // this loop here so it moves faster without introducing instability
    for (int t = 0; t < 2000; t++) {
        
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
                    // 2 triangles per quad
                    // values are definitely starting out as not nan
                    //println("i: " + i);
                    //println("j: " + j);
                    //println("balls i, j position: " + balls[i][j].position);
                    //println("balls i, j + 1 position: " + balls[i][j + 1].position);
                    //println("balls i + 1, j + 1 position: " + balls[i + 1][j + 1].position);
                    //println("balls i, j velocity: " + balls[i][j].velocity);
                    //println("balls i, j + 1 velocity: " + balls[i][j + 1].velocity);
                    //println("balls i + 1, j + 1 velocity: " + balls[i + 1][j + 1].velocity);
                    PVector leftTriangle = getDrag(balls[i][j], balls[i][j + 1], balls[i + 1][j + 1]);
                   PVector rightTriangle = getDrag(balls[i][j], balls[i + 1][j + 1], balls[i + 1][j]);
                    //println("leftTriangle: " + leftTriangle);
                    
                    //PVector leftTriangleSinglePointForce = PVector.div(leftTriangle, 3);// leftTriangle.div(3);
                    //PVector rightTriangleSinglePointForce = PVector.div(rightTriangle, 3);//rightTriangle.div(3);
                    
                    //println("leftTriangleSinglePointForce: " + leftTriangleSinglePointForce);
                    //println("rightTriangleSinglePointForce: " + rightTriangleSinglePointForce);
                    
                    //println("top left force before: " + balls[i][j].force);
                    /*if (j != 0) { //<>//
                        balls[i][j].force.add(leftTriangleSinglePointForce).add(rightTriangleSinglePointForce);
                    }
                    //println("top left force after: " + balls[i][j].force);
                    balls[i][j + 1].force.add(leftTriangleSinglePointForce);
                    balls[i + 1][j + 1].force.add(leftTriangleSinglePointForce).add(rightTriangleSinglePointForce);
                    if (j != 0) {
                        balls[i + 1][j].force.add(rightTriangleSinglePointForce);
                    }*/
                }
            }
        }
        
    
        // update acceleration/velocity/position - only want to update the non-anchor balls since the anchor balls shouldn't move
        for(int i = 0; i < ballCountHorizontal; i++) {
            for(int j = 1; j < ballCountVertical; j++) {
                // only want the gravity applied to a given non-anchor ball once
                balls[i][j].force.y += gravity * mass;
                balls[i][j].updateAccelerationVelocityPosition(0.00003);
            }
        }
        
        // collision with sphere
        if (collisionIsEnabled) {
            for(int i = 0; i < ballCountHorizontal; i++) {
                for(int j = 0; j < ballCountVertical; j++) {
                    float distance = PVector.dist(balls[i][j].position, collidingSpherePosition);
                    
                    if (distance < sphereRadius + 3) {
                        PVector sphereNormal = PVector.mult(PVector.sub(collidingSpherePosition, balls[i][j].position), -1);
                        sphereNormal.normalize();
                        PVector bounce = PVector.mult(sphereNormal, PVector.dot(balls[i][j].velocity, sphereNormal));
                        balls[i][j].velocity.sub(PVector.mult(bounce, 1.5));
                        balls[i][j].position.add(PVector.mult(sphereNormal, 3 + sphereRadius - distance));
                    }
                }
            }
        }
    }
    
    
    // drawing of sphere to collide with
    if (collisionIsEnabled) {
        fill(0, 210, 255);
        translate(collidingSpherePosition.x, collidingSpherePosition.y, collidingSpherePosition.z);
        sphere(0.75 * sphereRadius);
        translate(-1 * collidingSpherePosition.x, -1 * collidingSpherePosition.y, -1 * collidingSpherePosition.z);
    }

    // textured drawing of cloth
    for(int i = 0; i < ballCountHorizontal - 1; i++) {
        for(int j = 0; j < ballCountVertical - 1; j++) {
            beginShape();
            texture(texture);
            vertex(balls[i][j].position.x, balls[i][j].position.y, balls[i][j].position.z, 0, 0);
            vertex(balls[i][j + 1].position.x, balls[i][j + 1].position.y, balls[i][j + 1].position.z, 0, 1);
            vertex(balls[i + 1][j + 1].position.x, balls[i + 1][j + 1].position.y, balls[i + 1][j + 1].position.z, 1, 1);
            vertex(balls[i + 1][j].position.x, balls[i + 1][j].position.y, balls[i + 1][j].position.z, 1, 0);
            endShape();
        }
    }
}


/// Get drag force (f aero)
PVector getDrag(Ball corner1, Ball corner2, Ball corner3) {
    
    //PVector v = PVector.sub(PVector.div(PVector.add(corner1.velocity, PVector.add(corner2.velocity, corner3.velocity)), 3), velocityAir);
    /*PVector v = PVector.sub(PVector.div(PVector.add(corner1.velocity, PVector.add(corner2.velocity, corner3.velocity)), 3), velocityAir);
    //println("velocityAir: " + velocityAir);
    //println("corner2 position: " + corner2.position);
    //println("corner2 velocity: " + corner2.velocity);
    //println("corner3 velocity: " + corner3.velocity);
    //println("v first step: " + PVector.add(corner2.velocity, corner3.velocity));
    
    PVector n = new PVector();

    PVector.cross(PVector.sub(corner2.position, corner1.position), PVector.sub(corner3.position, corner1.position), n);
    // v's and n's values seem reasonable
    // n's magnitude is pretty large, but v dot n is huge - then consider that those are getting multiplied together (so no wonder the value is so big)
    
    println("n: " + n);
    println("v mag: " + v.mag());
    println("v dot n: " + v.dot(n));
    println("n mag: " + n.mag());
   */
   
   //println("v: " + v);
   //println("test");
   
   // return a zero vector
   return new PVector(0, 0, 0);
   
    // the return value is what seems huge - n and v seem reasonable - this huge value probably just compounds over time and eventually gets too big - I saw infinity
    //return PVector.mult(PVector.mult(n, -0.5 * airDensity * dragCoefficient), v.mag() * v.dot(n) / (2 * n.mag()));
}
