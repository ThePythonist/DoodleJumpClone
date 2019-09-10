Player player;
ArrayList<ArrayList<Platform>> platforms;

PImage background;

static class Settings {
  public static int platformRowCount = 6;
  public static float vertPlatformDistance = 200;
  public static float spaceToFirstPlatform = 50;

  public static float gravity = 0.5;
  public static float strafe = 10.0;
  public static float airResistance = 2.0;
  public static float jumpForce = -15.0;

  public static int minPlatformCountPerRow = 2;
  public static int maxPlatformCountPerRow = 5;
}


boolean pressingLeft = false;
boolean pressingRight = false;

float topPlatformHeight = 0;

int score = 0;

PFont scoreFont;

float scorePadding = 100;
float scoreFontSize = 96;

void setup() {
  size(1600, 900); 
  surface.setTitle("Doodle Jump Clone");
  PImage backgroundTile = loadImage("images/backgroundTile.png");
  background = createImage(ceil(width/(float)(backgroundTile.width))*backgroundTile.width, ceil(height/(float)(backgroundTile.height))*backgroundTile.height, RGB);
  for (int i=0; i<background.pixels.length; i++) {
    int xInBackground = i % background.width;
    int yInBackground = (i - xInBackground) / background.width;

    int xInTile = xInBackground % backgroundTile.width;
    int yInTile = yInBackground % backgroundTile.height;

    background.pixels[i] = backgroundTile.pixels[yInTile * backgroundTile.width + xInTile];
  }
  background.updatePixels();
  platforms = new ArrayList<ArrayList<Platform>>();

  scoreFont = createFont("Courier", 16, false);
  textFont(scoreFont, scoreFontSize);

  startGame();
}

void startGame() {
  score = 0;
  initPlayer();
  initPlatforms();
}

void initPlayer() {
  player = new Player(0, 0);
}

void initPlatforms () {
  float basePoint = player.y+player.myHeight+Platform.PLATFORM_HEIGHT/2 + Settings.spaceToFirstPlatform;
  Platform firstPlatform = new NormalPlatform(0, basePoint);
  platforms.clear();
  platforms.add(new ArrayList<Platform>());
  platforms.get(0).add(firstPlatform);
  for (int i=1; i<Settings.platformRowCount; i++) {
    platforms.add(newRandomPlatformRow(basePoint-i*Settings.vertPlatformDistance));
  }

  topPlatformHeight = basePoint-(Settings.platformRowCount-1)*Settings.vertPlatformDistance;
}

void keyPressed () {
  if (keyCode == LEFT) {
    pressingLeft = true;
  }
  if (keyCode == RIGHT) {
    pressingRight = true;
  }
}

void keyReleased () {
  if (keyCode == LEFT) {
    pressingLeft = false;
  }
  if (keyCode == RIGHT) {
    pressingRight = false;
  }
}

void draw () {
  tint(255);
  image(background, (width-background.width)/2.0, (height-background.height)/2.0);
  player.applyVerticalForce(Settings.gravity);
  player.checkCollisions(platforms, Settings.jumpForce);
  if (pressingLeft && !pressingRight) {
    player.applyHorizontalForce(-Settings.strafe);
  }
  if (pressingRight && !pressingLeft) {
    player.applyHorizontalForce(Settings.strafe);
  }
  player.dampenHorizontal(Settings.airResistance);
  player.update();
  player.follow();
  boolean allAboveScreen = true;
  for (int i=0; i<platforms.size(); i++) {
    if (shouldDestroyRow(platforms.get(i))) {
      topPlatformHeight -= Settings.vertPlatformDistance;
      platforms.set(i, newRandomPlatformRow(topPlatformHeight));
    }
    for (int j=platforms.get(i).size()-1; j>=0; j--) {
      platforms.get(i).get(j).display();
      if (!platforms.get(i).get(j).aboveScreen(player)) {
        allAboveScreen = false;
      }
      if (platforms.get(i).get(j).shouldDestroy(player)) {
        platforms.get(i).remove(j);
      }
    }
  }
  player.display();
  if (allAboveScreen) {
    startGame();
  }
  if (round(-player.y/100.0) > score) {
    score = round(-player.y/100.0);
  }
  fill(0, 0, 255);
  text(""+score, 0, player.y-height/2+scorePadding);
}

boolean shouldDestroyRow (ArrayList<Platform> row) {
  boolean allDestroy= true;
  for (Platform platform : row) {
    if (!platform.shouldDestroy(player)) {
      allDestroy =false;
    }
  }
  return allDestroy;
}

ArrayList<Platform> newRandomPlatformRow (float y) {
  ArrayList<Platform> row = new ArrayList<Platform>();

  int platformCount = Settings.minPlatformCountPerRow + floor(random(Settings.maxPlatformCountPerRow-Settings.minPlatformCountPerRow + 1));

  row.add(newRandomPlatform(y, row, 2));
  for (int i=1; i<platformCount; i++) {
    Platform newP = newRandomPlatform(y, row);
    if (newP != null) {
      row.add(newP);
    } else {
      break;
    }
  }
  return row;
}

Platform newRandomPlatform (float y, ArrayList<Platform> others) {
  return newRandomPlatform (y, others, random(1));
}

Platform newRandomPlatform (float y, ArrayList<Platform> others, float r) {
  Platform newPlatform;

  ArrayList<ArrayList<Float>> gaps = generateGaps(others);

  if (gaps.size() == 0) {
    println("No more gaps");
    return null;
  }


  ArrayList<Float> gap = gaps.get(floor(random(gaps.size())));
  float x = gap.get(0) + random(gap.get(1));


  if (r <= 0.1) {
    newPlatform = new OneJumpPlatform(x, y);
  } else if (r <= 0.2) {
    newPlatform = new GhostPlatform(x, y);
  } else {
    newPlatform = new NormalPlatform (x, y);
  }

  if (newPlatform.hittable) {
    float r2 = random(1);
    if (r2 <= 0.1) {
      newPlatform.item = new Spring();
    }
  }

  return newPlatform;
}

ArrayList<ArrayList<Float>> generateGaps (ArrayList<Platform> row) {
  ArrayList<ArrayList<Float>> gaps = new ArrayList<ArrayList<Float>>();
  if (row.size() == 0) {
    ArrayList<Float> gapList = new ArrayList<Float>();
    gapList.add(Platform.PLATFORM_WIDTH/2-width/2);
    gapList.add(width-Platform.PLATFORM_WIDTH);
    gaps.add(gapList);
  } else {
    float furthestRightX = -Float.MAX_VALUE;

    float furthestLeftX = Float.MAX_VALUE;

    for (int i=0; i<row.size(); i++) {
      if (row.get(i).x > furthestRightX) {
        furthestRightX = row.get(i).x;
      }
      if (row.get(i).x < furthestLeftX) {
        furthestLeftX = row.get(i).x;
      }
      float shortestDist = Float.MAX_VALUE;
      for (int j=0; j<row.size(); j++) {
        if (i != j) {
          float dist = row.get(j).x-row.get(i).x;
          if (dist > 0 && dist < shortestDist) {
            shortestDist = dist;
          }
        }
      }
      float gap = shortestDist - 2 * Platform.PLATFORM_WIDTH;
      if (gap > 0) {
        ArrayList<Float> gapList = new ArrayList<Float>();
        gapList.add(row.get(i).x + Platform.PLATFORM_WIDTH);
        gapList.add(gap);
        gaps.add(gapList);
      }
    }
    float rightGap = width/2.0 - furthestRightX - 1.5 * Platform.PLATFORM_WIDTH;
    if (rightGap > 0) {
      ArrayList<Float> gapList = new ArrayList<Float>();
      gapList.add(furthestRightX + Platform.PLATFORM_WIDTH);
      gapList.add(rightGap);
      gaps.add(gapList);
    }

    float leftGap = furthestLeftX + width/2.0 - 1.5 * Platform.PLATFORM_WIDTH;
    if (leftGap > 0) {
      ArrayList<Float> gapList = new ArrayList<Float>();
      gapList.add(-width/2.0+Platform.PLATFORM_WIDTH/2.0);
      gapList.add(leftGap);
      gaps.add(gapList);
    }
  }
  return gaps;
}
