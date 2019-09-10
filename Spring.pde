class Spring extends Item {

  float force = -10.0;

  public Spring () {
    super();
    image = loadImage("images/spring.png");
  }

  public void onCollide (Player player) {
    player.applyVerticalForce(force);
  }
}
