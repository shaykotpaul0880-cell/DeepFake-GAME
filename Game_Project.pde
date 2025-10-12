// Investigator Story Mode — Full Version with Enhanced Visuals & Message Style //<>//
import processing.video.*; 
import processing.sound.*; 
import java.io.File; 

enum Scene { INSTRUCTIONS, MENU, SEGMENT_SELECT, LEVEL_PLAY, SUMMARY } 
enum Segment { IMAGE, VIDEO, AUDIO } 

Scene scene = Scene.INSTRUCTIONS; 
Segment currentSegment = null; 

int ROOM_W = 1300, ROOM_H = 710; 
Player player; 
Bullet currentBullet = null; 
int score = 0; 
int currentLevel = 0; 

ArrayList<Evidence> realImages = new ArrayList<>(); 
ArrayList<Evidence> fakeImages = new ArrayList<>(); 
ArrayList<Evidence> realVideos = new ArrayList<>(); 
ArrayList<Evidence> fakeVideos = new ArrayList<>(); 
ArrayList<Evidence> realAudio = new ArrayList<>(); 
ArrayList<Evidence> fakeAudio = new ArrayList<>(); 
ArrayList<Level> levels = new ArrayList<>(); 

color accentCol = color(100, 180, 255); 

// Pause & Exit buttons
Rect pauseButton, menuButton; 
boolean gamePaused = false; 

void settings(){
  size(ROOM_W, ROOM_H); 
} 

void setup(){
  surface.setTitle("Investigator Story Mode"); 
  player = new Player(width/2, height-80); 
  textFont(createFont("Arial",18)); 

  // Buttons for pause and exit
  pauseButton = new Rect(width-200, 20, 80, 30); 
  menuButton = new Rect(width-100, 20, 80, 30); 

  // Preload media
  loadDatasetFolder("Real_Image", true, Segment.IMAGE); 
  loadDatasetFolder("Fake_Image", false, Segment.IMAGE); 
  loadDatasetFolder("Real_Video", true, Segment.VIDEO); 
  loadDatasetFolder("Fake_Video", false, Segment.VIDEO); 
  loadDatasetFolder("Real_Audio", true, Segment.AUDIO); 
  loadDatasetFolder("Fake_Audio", false, Segment.AUDIO); 
} 

void draw(){
  drawBackgroundGradient(); 
  switch(scene){
    case INSTRUCTIONS: drawInstructions(); break; 
    case MENU: drawMenu(); break; 
    case SEGMENT_SELECT: drawSegmentSelect(); break; 
    case LEVEL_PLAY: drawLevelPlay(); break; 
    case SUMMARY: drawSummary(); break; 
  } 
} 

void drawBackgroundGradient(){
  for(int i=0;i<height;i++){
    float inter = map(i,0,height,0,1); 
    color c = lerpColor(color(30,35,45), color(15,20,30), inter); 
    stroke(c); 
    line(0,i,width,i); 
  }
}

// --- Screens ---
void drawInstructions(){
  fill(255); 
  textAlign(CENTER,CENTER); 
  textSize(38); 
  text("Welcome, Investigator!", width/2, 100); 
  textSize(24); 
  text("Instructions:", width/2, 180); 
  textSize(18); 
  text("1. Select a segment (Images, Videos, Audio)\n" + 
       "2. You will see Real and Fake media side by side\n" + 
       "3. Use mouse to aim and shoot the Fake media\n" + 
       "4. Wrong hit shows a hint message and resets level\n" + 
       "5. Each dataset pair counts as one level\n" + 
       "6. Game ends after all levels are finished", width/2, 300); 
  textSize(20); 
  text("Press ENTER to continue to Menu", width/2, height-80); 
}

void drawMenu(){
  fill(255); 
  textAlign(CENTER,CENTER); 
  textSize(46); 
  text("Investigator: Provenance Unit", width/2, height/2-60); 
  textSize(20); 
  text("Press ENTER to continue", width/2, height/2+20); 
}

void drawSegmentSelect(){
  fill(255); 
  textAlign(CENTER,CENTER); 
  textSize(32); 
  text("Select Segment", width/2, 80); 
  float bw=300, bh=140, gap=60; 
  float startX = width/2 - (bw*3 + gap*2)/2; 
  drawSegmentOption(startX, height/2-bh/2, bw, bh, "Images", realImages.size(), fakeImages.size(), Segment.IMAGE); 
  drawSegmentOption(startX+(bw+gap), height/2-bh/2, bw, bh, "Videos", realVideos.size(), fakeVideos.size(), Segment.VIDEO); 
  drawSegmentOption(startX+2*(bw+gap), height/2-bh/2, bw, bh, "Audio", realAudio.size(), fakeAudio.size(), Segment.AUDIO); 
  textSize(16); 
  text("Press ESC to return to Menu", width/2, height-40); 
}

void drawSegmentOption(float x, float y, float w, float h, String title, int realCount, int fakeCount, Segment seg){
  boolean hover = mouseX>=x && mouseX<=x+w && mouseY>=y && mouseY<=y+h; 
  fill(hover?color(60,80,110):color(40,50,70)); 
  stroke(255,100); 
  strokeWeight(2); 
  rect(x,y,w,h,16); 
  noStroke(); 
  fill(255); 
  textAlign(CENTER,CENTER); 
  textSize(22); 
  text(title,x+w/2,y+28); 
  textSize(16); 
  text("Real: "+realCount+" Fake: "+fakeCount,x+w/2,y+64); 
}

// --- LEVEL PLAY ---
void drawLevelPlay(){
  if(currentLevel>=levels.size()){ scene=Scene.SUMMARY; return; } 
  Level lvl = levels.get(currentLevel); 

  if(!gamePaused){
    lvl.drawLevel(); 
    player.draw(); 
    if(currentBullet != null && currentBullet.active){
      currentBullet.update(); 
      currentBullet.draw(); 
      boolean hit = lvl.checkHit(currentBullet); 
      if(hit) currentBullet = null; 
    }
  } else {
    lvl.drawLevel(); 
    player.draw(); 
  }

  drawHoverButton(pauseButton, gamePaused?"Resume":"Pause"); 
  drawHoverButton(menuButton, "Exit"); 

  fill(0,100); 
  rect(20,20,160,70,12); 
  fill(255); 
  textAlign(LEFT,TOP); 
  textSize(18); 
  text("Score: "+score,30,30); 
  text("Level: "+(currentLevel+1)+"/"+levels.size(),30,55); 
}

void drawHoverButton(Rect r, String label){
  boolean hover = r.contains(mouseX,mouseY); 
  fill(hover?color(80,200,80):color(60,180,60)); 
  rect(r.x,r.y,r.w,r.h,8); 
  fill(255); 
  textAlign(CENTER,CENTER); 
  textSize(16); 
  text(label,r.x+r.w/2,r.y+r.h/2); 
}

void drawSummary(){
  fill(255); 
  textAlign(CENTER,CENTER); 
  textSize(34); 
  text("Case Finished!", width/2, height/2-40); 
  textSize(22); 
  text("Final Score: "+score+" / "+levels.size(), width/2, height/2+10); 
  textSize(18); 
  text("Press ENTER to go back to segment selection", width/2, height/2+60); 
}

// --- INPUT ---
void mousePressed(){
  if(scene==Scene.SEGMENT_SELECT){
    float bw=300, bh=140, gap=60; 
    float startX = width/2 - (bw*3 + gap*2)/2; 
    float y = height/2 - bh/2; 
    if(mouseX>=startX && mouseX<=startX+bw && mouseY>=y && mouseY<=y+bh) startSegment(Segment.IMAGE); 
    else if(mouseX>=startX+(bw+gap) && mouseX<=startX+(bw+gap)+bw && mouseY>=y && mouseY<=y+bh) startSegment(Segment.VIDEO); 
    else if(mouseX>=startX+2*(bw+gap) && mouseX<=startX+2*(bw+gap)+bw && mouseY>=y && mouseY<=y+bh) startSegment(Segment.AUDIO); 
  } else if(scene==Scene.LEVEL_PLAY){
    Level lvl = levels.get(currentLevel); 
    if(pauseButton.contains(mouseX, mouseY)){ gamePaused=!gamePaused; if(gamePaused) lvl.stopAllMedia(); return; } 
    if(menuButton.contains(mouseX, mouseY)){ gamePaused=false; lvl.stopAllMedia(); scene=Scene.SEGMENT_SELECT; return; } 
    if(gamePaused) return; 

    boolean clickedButton=false; 
    if(lvl.seg==Segment.VIDEO||lvl.seg==Segment.AUDIO){
      if(lvl.leftButton.contains(mouseX, mouseY)) { lvl.toggleLeft(); clickedButton=true; } 
      if(lvl.rightButton.contains(mouseX, mouseY)) { lvl.toggleRight(); clickedButton=true; } 
    } 
    if(!clickedButton){ 
      if(lvl.leftRect.contains(mouseX, mouseY)||lvl.rightRect.contains(mouseX, mouseY)){
        if(currentBullet==null) currentBullet=new Bullet(player.x,player.y-20,mouseX,mouseY); 
      } 
    } 
  } 
}

void keyPressed(){
  if(key==ESC) key=0; // disable default ESC closing
  if(scene==Scene.INSTRUCTIONS && key==ENTER) scene=Scene.MENU; 
  else if(scene==Scene.MENU && key==ENTER) scene=Scene.SEGMENT_SELECT; 
  else if(scene==Scene.SUMMARY && key==ENTER) scene=Scene.SEGMENT_SELECT; 
  else if(scene==Scene.SEGMENT_SELECT && key==ESC) scene=Scene.MENU; 
}

// --- DATASET ---
void loadDatasetFolder(String folderName, boolean isReal, Segment seg){
  File folder = new File(dataPath(folderName)); 
  if(!folder.exists()){ println("Missing folder: "+folderName); return; } 
  File[] files = folder.listFiles(); 
  if(files==null||files.length==0){ println("No files in "+folderName); return; } 
  for(File f: files){
    if(!f.isFile()) continue; 
    String path = folderName+"/"+f.getName(); 
    try{
      Evidence e=null; 
      if(seg==Segment.IMAGE){ PImage img=loadImage(path); if(img!=null)e=new Evidence(img,null,null,isReal,seg); } 
      else if(seg==Segment.VIDEO){ Movie mv=new Movie(this,path); mv.pause(); e=new Evidence(null,mv,null,isReal,seg); } 
      else if(seg==Segment.AUDIO){ SoundFile sf=new SoundFile(this,path); e=new Evidence(null,null,sf,isReal,seg); } 
      if(e!=null){
        if(seg==Segment.IMAGE){ if(isReal) realImages.add(e); else fakeImages.add(e); } 
        else if(seg==Segment.VIDEO){ if(isReal) realVideos.add(e); else fakeVideos.add(e); } 
        else if(seg==Segment.AUDIO){ if(isReal) realAudio.add(e); else fakeAudio.add(e); } 
      }
    }catch(Exception ex){ println("Error loading "+path+": "+ex.getMessage()); } 
  } 
}

// --- START SEGMENT ---
void startSegment(Segment seg){
  currentSegment = seg; levels.clear(); currentLevel=0; score=0; 
  ArrayList<Evidence> realPool=null,fakePool=null; 
  if(seg==Segment.IMAGE){ realPool=realImages; fakePool=fakeImages; } 
  if(seg==Segment.VIDEO){ realPool=realVideos; fakePool=fakeVideos; } 
  if(seg==Segment.AUDIO){ realPool=realAudio; fakePool=fakeAudio; } 
  int pairs = min(realPool.size(), fakePool.size()); 
  for(int i=0;i<pairs;i++) levels.add(new Level(realPool.get(i),fakePool.get(i),seg)); 
  scene=Scene.LEVEL_PLAY; 
}

// --- CLASSES ---
class Player{
  float x,y,r=18; 
  Player(float xx,float yy){ x=xx;y=yy; } 
  void draw(){ 
    noStroke(); fill(accentCol,200); ellipse(x,y,r*2,r*2); 
    fill(accentCol,50); ellipse(x,y,r*4,r*4); 
  } 
}

class Bullet{
  float x,y,speedX,speedY,r=8; boolean active=true; 
  Bullet(float startX,float startY,float targetX,float targetY){
    x=startX; y=startY; 
    float angle = atan2(targetY-startY,targetX-startX); 
    speedX = cos(angle)*15; speedY = sin(angle)*15; 
  } 
  void update(){ x+=speedX; y+=speedY; if(x<0||x>width||y<0||y>height) active=false; } 
  void draw(){ fill(255,60,60); noStroke(); ellipse(x,y,r*2,r*2); } 
}

class Evidence{
  PImage img; Movie vid; SoundFile snd; boolean isReal; Segment seg; 
  Evidence(PImage i, Movie v, SoundFile s, boolean r, Segment seg){ 
    img=i; vid=v; snd=s; isReal=r; this.seg=seg; 
    if(vid!=null) vid.jump(0); 
    if(snd!=null) snd.stop(); 
  } 
}

class Rect{ 
  float x,y,w,h; 
  Rect(float xx,float yy,float ww,float hh){ x=xx;y=yy;w=ww;h=hh; } 
  boolean contains(float px,float py){ return px>=x && px<=x+w && py>=y && py<=y+h; } 
}
class Level {
  Evidence left, right;
  boolean realLeft;
  Segment seg;
  Rect leftRect, rightRect;
  boolean showMessage = false;
  String message = "";
  int messageTimer = 0;
  Rect leftButton, rightButton;
  boolean leftPlaying = false, rightPlaying = false;

  Level(Evidence r, Evidence f, Segment s){
    seg = s;
    if(random(1) < 0.5){
      left = r; right = f; realLeft = r.isReal;
    } else {
      left = f; right = r; realLeft = f.isReal;
    }
    leftRect = new Rect(width/4-200, height/2-160, 400, 320);
    rightRect = new Rect(3*width/4-200, height/2-160, 400, 320);
    leftButton = new Rect(leftRect.x, leftRect.y+leftRect.h+10, 80, 30);
    rightButton = new Rect(rightRect.x, rightRect.y+rightRect.h+10, 80, 30);
  }

  void drawLevel(){
    stroke(255,100); strokeWeight(2);
    fill(50,60,70);
    rect(leftRect.x-5,leftRect.y-5,leftRect.w+10,leftRect.h+10,12);
    rect(rightRect.x-5,rightRect.y-5,rightRect.w+10,rightRect.h+10,12);
    noStroke();

    if(seg == Segment.IMAGE){
      if(left.img != null) image(left.img,leftRect.x,leftRect.y,leftRect.w,leftRect.h);
      if(right.img != null) image(right.img,rightRect.x,rightRect.y,rightRect.w,rightRect.h);
    } else if(seg == Segment.VIDEO){
      if(left.vid != null && left.vid.available()) left.vid.read();
      if(right.vid != null && right.vid.available()) right.vid.read();
      if(left.vid != null) image(left.vid,leftRect.x,leftRect.y,leftRect.w,leftRect.h);
      if(right.vid != null) image(right.vid,rightRect.x,rightRect.y,rightRect.w,rightRect.h);
      drawButton(leftButton,leftPlaying);
      drawButton(rightButton,rightPlaying);
    } else if(seg == Segment.AUDIO){
      fill(40); rect(leftRect.x,leftRect.y,leftRect.w,leftRect.h,8);
      fill(255); textAlign(CENTER,CENTER); textSize(24); text("Audio 1", leftRect.x + leftRect.w/2, leftRect.y + leftRect.h/2);
      fill(40); rect(rightRect.x,rightRect.y,rightRect.w,rightRect.h,8);
      fill(255); textAlign(CENTER,CENTER); textSize(24); text("Audio 2", rightRect.x + rightRect.w/2, rightRect.y + rightRect.h/2);
      drawButton(leftButton,leftPlaying);
      drawButton(rightButton,rightPlaying);
    }

    if(showMessage){
      fill(message.startsWith("Wrong") ? color(255,100,50) : color(60,200,60),200);
      rect(width/2-320,height-100,640,60,12);
      fill(255); textAlign(CENTER,CENTER); textSize(20); text(message,width/2,height-70);
      messageTimer--;
      if(messageTimer <= 0) showMessage = false;
    }
  }

  void drawButton(Rect r, boolean playing){
    fill(playing ? color(60,200,60) : color(180,60,60));
    rect(r.x,r.y,r.w,r.h,6);
    fill(255); textAlign(CENTER,CENTER); textSize(14); text(playing ? "Pause" : "Play", r.x+r.w/2, r.y+r.h/2);
  }

  void toggleLeft(){
    if(seg == Segment.VIDEO){
      stopRightVideo();
      if(leftPlaying){ left.vid.pause(); leftPlaying=false; } 
      else{ left.vid.jump(0); left.vid.play(); leftPlaying=true; }
    } else if(seg == Segment.AUDIO){
      stopRightAudio();
      if(leftPlaying){ left.snd.stop(); leftPlaying=false; }
      else{ left.snd.play(); leftPlaying=true; }
    }
  }

  void toggleRight(){
    if(seg == Segment.VIDEO){
      stopLeftVideo();
      if(rightPlaying){ right.vid.pause(); rightPlaying=false; } 
      else{ right.vid.jump(0); right.vid.play(); rightPlaying=true; }
    } else if(seg == Segment.AUDIO){
      stopLeftAudio();
      if(rightPlaying){ right.snd.stop(); rightPlaying=false; }
      else{ right.snd.play(); rightPlaying=true; }
    }
  }

  void stopLeftVideo(){ if(left.vid != null){ left.vid.pause(); leftPlaying=false; left.vid.jump(0); } }
  void stopRightVideo(){ if(right.vid != null){ right.vid.pause(); rightPlaying=false; right.vid.jump(0); } }
  void stopLeftAudio(){ if(left.snd != null){ left.snd.stop(); leftPlaying=false; } }
  void stopRightAudio(){ if(right.snd != null){ right.snd.stop(); rightPlaying=false; } }

  void stopAllMedia(){ stopLeftVideo(); stopRightVideo(); stopLeftAudio(); stopRightAudio(); }

  boolean checkHit(Bullet b){
    boolean hitDetected=false;
    if(leftRect.contains(b.x,b.y)){
      hitDetected=true; stopAllMedia();
      if(!left.isReal){ score++; currentLevel++; if(currentLevel>=levels.size()) currentLevel=levels.size(); } 
      else { onFail(seg); }
      b.active=false;
    } else if(rightRect.contains(b.x,b.y)){
      hitDetected=true; stopAllMedia();
      if(!right.isReal){ score++; currentLevel++; if(currentLevel>=levels.size()) currentLevel=levels.size(); }
      else { onFail(seg); }
      b.active=false;
    }
    return hitDetected;
  }

  void onFail(Segment s){
    stopAllMedia(); message="Wrong! Hint: " + hintText(s); showMessage=true; messageTimer=240;
    println(message); currentLevel=0; score=0;
  }

  String hintText(Segment s){
    if(s==Segment.IMAGE) return "Look for blurriness, artifacts, unusual patterns in images.";
    else if(s==Segment.VIDEO) return "Look for unnatural movements, glitches, or irregular frames in videos.";
    else if(s==Segment.AUDIO) return "Listen for distortions, unnatural edits, or repeated patterns in audio.";
    else return "";
  }
}


void movieEvent(Movie m){ m.read(); }
