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

void setup() {
    size(640, 360, P2D);

    noStroke();
    

  
}

void draw() {

     circle(50, 40, 20);
}
