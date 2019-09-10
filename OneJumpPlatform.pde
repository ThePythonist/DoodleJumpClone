class OneJumpPlatform extends Platform {
  public OneJumpPlatform (float x, float y) {
    super(x, y);
    myColor = color(255, 128, 75);
  }

  public void onCollide (Player player) {
    super.onCollide(player);
    destroyed = true;
  }
}
