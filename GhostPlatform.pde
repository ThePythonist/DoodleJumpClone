class GhostPlatform extends Platform {

  public GhostPlatform (float x, float y) {
    super(x, y);
    myColor = color(100, 70, 0, 100);
    hittable = false;
  }

  public void onCollide(Player player) {
    super.onCollide(player);
    this.destroyed = true;
  }
}
