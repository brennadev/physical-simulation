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
    }
}
