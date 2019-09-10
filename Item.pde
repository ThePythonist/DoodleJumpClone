abstract class Item {

  PImage image;

  public Item () {
  }

  public void onCollide(Player player) {
  }

  public void display(float x, float y) {
    tint(255);
    image(image, x-image.width/2.0, y-Platform.PLATFORM_HEIGHT/2.0 - image.height);
  }
}
