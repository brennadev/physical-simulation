void keyPressed() {
    switch (keyCode) {
        case LEFT:
        collidingSpherePosition.x -= 20;
        break;
        
        case RIGHT:
        collidingSpherePosition.x += 20;
        break;
        
        case SHIFT:
        shiftKeyIsDown = true;
        break;
        
        case UP:
        if (shiftKeyIsDown) {
            collidingSpherePosition.y -= 20;
        } else {
            collidingSpherePosition.z -= 20;
        }
        break;
        
        case DOWN:
        if (shiftKeyIsDown) {
            collidingSpherePosition.y += 20;
        } else {
            collidingSpherePosition.z += 20;
        }
        break;
    }
}

void keyReleased() {
    if (keyCode == SHIFT) {
        shiftKeyIsDown = false;
    }
}
