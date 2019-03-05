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
