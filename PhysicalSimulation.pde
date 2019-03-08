// Copyright 2019 Brenna Olson. All rights reserved. You may download this code for informational purposes only. //<>//

import peasy.*;

// Constants
float k = 50;    // spring constant
float kv = 2;    // related to k; the dampening constant
float mass = 1;
float gravity = 3;
float stringRestLength = 1;
int floorLocation = 700;

// Drag values
boolean dragIsEnabled = true;    // true if drag should be shown; false if it shouldn't be shown; set this value before running program
final float dragCoefficient = 8;
final float airDensity = 1.2;     // from physics book at 20 degrees celsius and 1 atm
PVector velocityAir = new PVector(0, 0, -1);    // vair - get some values going in the z direction so that's shown too

// Rendering stuff
PeasyCam camera;
PImage texture;

// Cloth-Object Collision
boolean collisionIsEnabled = true;    // true if collision should be shown; false if it shouldn't be shown; set this value before running program
PVector collidingSpherePosition = new PVector(0, -2, 0);
float sphereRadius = 5;
boolean shiftKeyIsDown = false;    // for user interaction with the sphere's position


// Ball and thread data
//////////////////////////////////////////////////////////////////////////////////////////////////////////


int ballCountHorizontal = 20;
int ballCountVertical = 20;

Ball[][] balls = new Ball[ballCountHorizontal][ballCountVertical];

/// All strings that connect balls together - hold references to the needed balls
ConnectingString[][] verticalStrings = new ConnectingString[ballCountHorizontal][ballCountVertical - 1];
ConnectingString[][] horizontalStrings = new ConnectingString[ballCountHorizontal - 1][ballCountVertical];


// Drawing loop
//////////////////////////////////////////////////////////////////////////////////////////////////////////

void setup() {
    size(900, 700, P3D);

    camera = new PeasyCam(this, 0, 0, 0, 70);    // based on example usage in the PeasyCam documentation
    mass = 1;

    texture = loadImage("pattern.PNG");
    textureMode(NORMAL);    // I'm so used to working in normalized device coordinates
    noStroke();
  
    // initialize based on strings in the scene rather than balls in the scene (especially helpful once the horizontal threads go in)
    float startingY = -20;    // get the simulation out of the top left
    float startingX = -5;    // get the simulation out of the top left
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
    for (int t = 0; t < 425; t++) {
        
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
                    PVector leftTriangle = getDrag(balls[i][j], balls[i][j + 1], balls[i + 1][j + 1]);
                    PVector rightTriangle = getDrag(balls[i][j], balls[i + 1][j + 1], balls[i + 1][j]);

                    PVector leftTriangleSinglePointForce = PVector.div(leftTriangle, 3);// leftTriangle.div(3);
                    PVector rightTriangleSinglePointForce = PVector.div(rightTriangle, 3);//rightTriangle.div(3);
                    

                    if (j != 0) {
                        balls[i][j].force.add(leftTriangleSinglePointForce).add(rightTriangleSinglePointForce);
                    }
                    balls[i][j + 1].force.add(leftTriangleSinglePointForce);
                    balls[i + 1][j + 1].force.add(leftTriangleSinglePointForce).add(rightTriangleSinglePointForce);
                    if (j != 0) {
                        balls[i + 1][j].force.add(rightTriangleSinglePointForce);
                    }
                }
            }
        }
        
    
        // update acceleration/velocity/position - only want to update the non-anchor balls since the anchor balls shouldn't move
        for(int i = 0; i < ballCountHorizontal; i++) {
            for(int j = 1; j < ballCountVertical; j++) {
                // only want the gravity applied to a given non-anchor ball once
                balls[i][j].force.y += gravity * mass;
                balls[i][j].updateAccelerationVelocityPosition(0.00006);
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
        sphere(0.9 * sphereRadius);
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
    
    PVector v = PVector.sub(PVector.div(PVector.add(corner1.velocity, PVector.add(corner2.velocity, corner3.velocity)), 3), velocityAir);
    
    PVector n = new PVector();
    PVector.cross(PVector.sub(corner2.position, corner1.position), PVector.sub(corner3.position, corner1.position), n);
   
    // the return value is what seems huge - n and v seem reasonable - this huge value probably just compounds over time and eventually gets too big - I saw infinity
    return PVector.mult(PVector.mult(n, -0.5 * airDensity * dragCoefficient), v.mag() * v.dot(n) / (2 * n.mag()));
}
