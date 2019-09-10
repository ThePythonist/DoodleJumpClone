abstract class Platform {

  public static final float PLATFORM_WIDTH = 100;
  public static final float PLATFORM_HEIGHT = 20;

  public float x;
  public float y;

  public Item item;

  PImage image;

  boolean destroyed = false;
  boolean hittable = true;

  color myColor;


  public Platform (float x, float y) {
    this.x = x;
    this.y = y;
    image = loadImage("images/platform.png");
  }

  public void display () {
    tint(myColor);
    image(image, x - PLATFORM_WIDTH/2, y - PLATFORM_HEIGHT/2, PLATFORM_WIDTH, PLATFORM_HEIGHT);
    if (item != null) {
      item.display(x, y);
    }
  }

  public boolean shouldDestroy (Player player) {
    return belowScreen (player) || destroyed;
  }

  public boolean belowScreen(Player player) {
    return y > player.y + height/2.0 + PLATFORM_HEIGHT/2.0;
  }

  public boolean aboveScreen(Player player) {
    return y < player.y - height/2.0 - PLATFORM_HEIGHT/2.0;
  }

  public void onCollide (Player player)
  {
    if (item != null) {
      item.onCollide(player);
    }
  }
}
