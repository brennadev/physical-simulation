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
    
    void update(float dt, PVector stringTop) {
        float dx = position.x - stringTop.x;
        float dy = position.y - stringTop.y;
        
        float stringLength = sqrt(dx * dx + dy * dy);
        
        float stringF = -k * (stringLength - stringRestLength);
        
        float dirX = dx / stringLength;
        float dirY = dy / stringLength;
        
        float dampFX = -kv * (velocity.x - 0);
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

Ball top = new Ball();
Ball bottom = new Ball();

int ballCount = 2;

/// All balls in scene. The order they appear in the array is the order they'll be connected in.
Ball[] balls = new Ball[ballCount];



void setup() {
    size(640, 360, P2D);

    noStroke();
    
    top.position = new PVector(50, 40);
    bottom.position = new PVector(50, 70);
    
    //top.position.x = 50;
    //top.position.y = 40;
    
    //bottom.position.x = 50;
    //bottom.position.y = 70;
  
    balls[0] = top;
    balls[1] = bottom;
}

void draw() {

    for(int i = 0; i < 2; i++) {
        circle(balls[i].position.x, balls[i].position.y, 20);
        
        // only draw a line if we're not at the bottom ball
        if (i < ballCount - 1) {
            stroke(0);
            line(balls[i].position.x, balls[i].position.y, balls[i + 1].position.x, balls[i + 1].position.y);
        }
    }
     //circle(50, 40, 20);
}
