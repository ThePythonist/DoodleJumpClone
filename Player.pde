class Player {
  public float x;
  public float y;
  public float myWidth;
  public float myHeight;

  float xVelocity;
  float yVelocity;

  PImage image;
  PImage flippedImage;

  boolean flipped = false;

  public Player (float x, float y) {
    this.x = x;
    this.y = y;
    myWidth = 75;
    myHeight = 75;
    xVelocity = 0;
    yVelocity = 0;

    image = loadImage("images/player.png");
    flippedImage = createImage(image.width, image.height, ARGB);
    for (int i=0; i<flippedImage.pixels.length; i++) {
      int xInFlipped = i % flippedImage.width;
      int yInFlipped = (i - xInFlipped) / flippedImage.width;

      int xInRegular = image.width-1-xInFlipped;
      flippedImage.pixels[i] = image.pixels[yInFlipped * image.width + xInRegular];
    }
    flippedImage.updatePixels();
  }

  public void follow () {
    translate(width/2.0, height/2.0-y);
  }

  public void display () {
    PImage toDraw = flipped? flippedImage : image;
    image (toDraw, x-myWidth/2.0, y-myHeight/2.0);
    if (x-myWidth/2.0 < -width/2.0) {
      image (toDraw, x - myWidth/2.0 + width, y-myHeight/2.0);
    }
    if (x+myWidth/2.0 > width/2.0) {
      image (toDraw, x - myWidth/2.0 - width, y-myHeight/2.0);
    }
  }

  public void update () {
    x += xVelocity;
    y += yVelocity;
    
    if (x+myWidth/2.0 < -width/2.0){
      x += width;
    }
    
    if (x-myWidth/2.0 > width/2.0){
      x -= width;
    }

    if (xVelocity > 0 && !flipped) {
      flipped = true;
    }
    if (xVelocity < 0 && flipped) {
      flipped = false;
    }
  }

  public void applyVerticalForce(float force) {
    yVelocity += force;
  }

  public void applyHorizontalForce (float force) {
    xVelocity += force;
  }

  public void dampenHorizontal (float factor) {
    xVelocity = xVelocity/factor;
  }

  public void checkCollisions (ArrayList<ArrayList<Platform>> platforms, float jumpForce) {
    if (yVelocity > 0) {
      for (ArrayList<Platform> platformRow : platforms) {
        for (Platform platform : platformRow) {
          if (collidesWith(platform)) {
            if (platform.hittable) {
              yVelocity = jumpForce;
            }
            platform.onCollide(this);
            break;
          }
        }
      }
    }
  }
  
  boolean collidesAtX(float x, Platform platform){
    return x >= platform.x - myWidth/2.0 - Platform.PLATFORM_WIDTH/2.0 && x <= platform.x + myWidth/2.0 + Platform.PLATFORM_WIDTH/2.0 && y >= platform.y - myHeight/2.0 - Platform.PLATFORM_HEIGHT/2.0 && y <= platform.y - myHeight/2.0 + Platform.PLATFORM_HEIGHT/2.0;
  }

  boolean collidesWith (Platform platform) {
    boolean realMeCollides = collidesAtX(x, platform);
    boolean fakeMeCollides = false;
    if (x - myWidth/2.0 < width/2.0){
      fakeMeCollides = collidesAtX(x+width, platform);
    }
    if (x + myWidth/2.0 > width/2.0){
      fakeMeCollides = collidesAtX(x-width, platform);
    }
    return realMeCollides || fakeMeCollides;
  }
}
