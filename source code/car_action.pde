import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import processing.serial.*;

Serial serialPort;
Serial serialLego;
JTextField field;

int RECT_SIZE_WIDTH = 45;        //車体の横幅
int RECT_SIZE_HEIGHT = 100;      //車体の縦幅
int playerX;                     //プレイヤのx座標
int playerY;                     //プレイヤのy座標
int enemyX;                      //敵のx座標
int enemyY;                      //敵のy座標
int fadeY;                       //残像の座標
float difference = 0;            //リセット時差
float difference2 = 0;
String playerMoveRight;          //右に曲がったか
String message = "C";
boolean enemyDead = true;        //敵が画面に表示されているか
boolean enemyDead2 = true;
float[] Random = new float[10];  //敵の車線
float RandomValue = random(5);   //敵の数
boolean gameover = false;        //ゲームオーバの判定
boolean gameover2 = false;
float rValue1 = 0;
float rValue2 = 0;
float base_time = millis();      //開始からの時間
boolean through = false;
float[] number = new float[10];
int point = 0;
boolean[] get = new boolean[10];
int quater_width = RECT_SIZE_WIDTH/4;
int quater_height = RECT_SIZE_HEIGHT/4;
int one_sixth_height = RECT_SIZE_HEIGHT/6;
int grade_time = 20;

float clear_time;
float start_time;
float finish_time;
boolean first_stage = true;
boolean second_stage = false;

void setup(){
//  serialPort = new Serial(this, "com4", 921600);
//  serialLego = new Serial(this, "com6", 921600);
  size(500, 500);
  frameRate(30);
  playerX = width / 2 - RECT_SIZE_WIDTH/ 2;
  playerY = 3 * height / 4 - RECT_SIZE_HEIGHT/2;
  fadeY = playerY;
  playerMoveRight = "C";
  enemyDead = true;
  
  noStroke();
  fill(255);
}

void draw(){
  // player
  if(first_stage)
  {
  if(playerMoveRight == "A")
  {
    playerX += 10;
    if(playerX >= width - RECT_SIZE_WIDTH)
    {
      playerX = width - RECT_SIZE_WIDTH;
    }
  }
  if(playerMoveRight == "B")
  {
    playerX -= 10;
    if(playerX <= 0)
    {
      playerX = 0;
    }
  }
  background(200);
  for(int i = 0;i < 10; i++)
  {
    for(int j = 0; j < 10; j++)
    {
      stroke(255);
      line(i * width/10, j * height/10, i * width/10, j * height/10 + 7 * height /100);
    }
  }
  for(int i = 0;i < 10; i++)
  {
    for(int j = 0; j < 10; j++)
    {
      stroke(255);
      line(i * width/10+1, j * height/10, i * width/10 + 1, j * height/10 + 7 * height /100);
    }
  }
  for(int i = 0;i < 10; i++)
  {
    for(int j = 0; j < 10; j++)
    {
      stroke(255);
      line(i * width/10+2, j * height/10, i * width/10+2, j * height/10 + 7 * height /100);
    }
  }
  for(int i = 0;i < 10; i++)
  {
    for(int j = 0; j < 10; j++)
    {
      stroke(255);
      line(i * width/10+3, j * height/10, i * width/10+3, j * height/10 + 7 * height /100);
    }
  }
  for(int i = 0;i < 10; i++)
  {
    for(int j = 0; j < 10; j++)
    {
      stroke(255);
      line(i * width/10+4, j * height/10, i * width/10+4, j * height/10 + 7 * height /100);
    }
  }
  for(int i = 0;i < 10; i++)
  {
    for(int j = 0; j < 10; j++)
    {
      stroke(255);
      line(i * width/10+5, j * height/10, i * width/10+5, j * height/10 + 7 * height /100);
    }
  }
  noStroke();
  fill(255, 0, 0);
  rect(playerX,playerY,RECT_SIZE_WIDTH,RECT_SIZE_HEIGHT); //車体
  for(int i = 5; i > 1; i--)
  {
    if(playerMoveRight == "A" && !(playerX + RECT_SIZE_WIDTH >= width))
    {
      fadeY += 20;
      fill(255, 0, 0, 10*i);
      rect(playerX + 3*(i - 6) - 3*i,fadeY,RECT_SIZE_WIDTH - 4*(i - 6), RECT_SIZE_HEIGHT + 5*(i - 6)); //車体
      fadeY -= 20;
    }
    if(playerMoveRight == "B" && playerX != 0)
    {
      fadeY += 20;
      fill(255, 0, 0, 10*i);
      rect(playerX + 3*(i - 6) + 3*i,fadeY,RECT_SIZE_WIDTH - 4*(i - 6), RECT_SIZE_HEIGHT + 5*(i - 6)); //車体
      fadeY -= 20;
    }
    if(playerMoveRight == "C" || playerX == 0 || playerX + RECT_SIZE_WIDTH >= width)
    {
      fadeY += 20;
      fill(255, 0, 0, 10*i);
      rect(playerX + 2 * (i - 6),fadeY,RECT_SIZE_WIDTH - 4*(i - 6), RECT_SIZE_HEIGHT + 5*(i - 6)); //車体
      fadeY -= 20;
    }
  }
  fill(0, 255, 255);
  rect(playerX + quater_width / 2,playerY + one_sixth_height, 3 * quater_width, one_sixth_height); //窓前
  fill(0, 255, 255);
  rect(playerX + quater_width / 2,playerY + 4 * one_sixth_height, 3 * quater_width, one_sixth_height); //窓後ろ
  fill(0);
  rect(playerX - quater_width/2, playerY + 4 * one_sixth_height, quater_width/2, one_sixth_height); //タイヤ左後ろ
  fill(0);
  rect(playerX + RECT_SIZE_WIDTH, playerY + 4 * one_sixth_height, quater_width/2, one_sixth_height);
  stroke(0);  
  line(playerX, playerY,playerX + quater_width / 2,playerY + one_sixth_height);
  stroke(0);  
  line(playerX + 7 * quater_width/ 2, playerY + one_sixth_height,playerX + RECT_SIZE_WIDTH,playerY);
  stroke(0);  
  line(playerX, playerY + RECT_SIZE_HEIGHT,playerX + quater_width / 2,playerY + 5 * one_sixth_height);
  stroke(0);  
  line(playerX + 7 * quater_width/2, playerY + 5 * one_sixth_height, playerX + RECT_SIZE_WIDTH,playerY + RECT_SIZE_HEIGHT);
  stroke(0);  
  line(playerX + quater_width/2, playerY + 2 * one_sixth_height, playerX + quater_width / 2,playerY + 5 * one_sixth_height);  
  stroke(0);  
  line(playerX + 7 * quater_width/2, playerY + 2 * one_sixth_height,playerX + 7 * quater_width/2, playerY + 4 * one_sixth_height);
  fill(0);
  rect(playerX - quater_width/2, playerY + one_sixth_height, quater_width/2, one_sixth_height);
  fill(0);
  rect(playerX - quater_width/2, playerY + one_sixth_height, quater_width/2, one_sixth_height);
  fill(0);
  rect(playerX + RECT_SIZE_WIDTH, playerY + one_sixth_height, quater_width/2, one_sixth_height);
  fill(0);
  rect(playerX + RECT_SIZE_WIDTH, playerY + one_sixth_height, quater_width/2, one_sixth_height);

//////////////////////////////////
  //time_grade
  
  if(point == 50)
  {
    fill(0);
    textSize(25);
    text("good", width / 2, height /2);
  }
  if(point == 100)
  {
    fill(0);
    textSize(30);
    text("nice", width / 2, height /2);
  }
  if(point == 150)
  {
    fill(0);
    textSize(35);
    text("great", width / 2, height /2);
  }
  if(point == 200)
  {
    fill(0);
    textSize(40);
    text("brilliant", width / 2, height /2);
  }
  if(point == 300)
  {
    fill(0);
    textSize(45);
    text("wonderful", width / 2, height /2);
  }
  if(point == 500)
  {
    fill(0);
    textSize(50);
    text("amazing", width / 2, height /2);
  }
  
////////////////////////////////
  //enemy
  float time = millis()/1000;
  time -= difference;
  if(enemyDead)
  {
    RandomEvent();
    rValue1 = RandomValue;
    difference = millis()/ 1000;
    enemyDead = false;
   }
  else
  {
    for(int i = 0; i < rValue1 ;i++)
    {
      noStroke();
      fill(150,100,0);
      rect(Random[i]/10.0 * width, 150 * time, RECT_SIZE_WIDTH, RECT_SIZE_HEIGHT);
    }
//  text(time/1000.0, 50, 100);
    if(50 * time + 3 * RECT_SIZE_HEIGHT >= height)
    {
      enemyDead = true;
    }
    for(int i = 0; i < rValue1; i++)
    {
      if(((Random[i]/10.0 * width <= playerX)&&(playerX < Random[i]/10.0 * width + RECT_SIZE_WIDTH) && (playerY < 150 * (time - 1) + RECT_SIZE_HEIGHT) && (playerY > 150 * (time - 1))
        ||((playerX <= Random[i]/10.0 * width) && (Random[i]/10.0 * width < playerX + RECT_SIZE_WIDTH) && (playerY < 150 * (time - 1) + RECT_SIZE_HEIGHT) && (playerY > 150 * (time - 1)))))
      {
        gameover = true;
      }
    }
    for(int i = 0; i < rValue1; i++)
    {
      for(int j = 0; j < 10; j++)
      {
        if(Random[i] == j)
        number[j] = 1;
      }
    }
    if(gameover)
    {
      GameOver();
    }
  }

////////////////////////
//item
  /*
  if(time >= 2)
  {
  float time2 = time - 2;
  time2 -= difference2;
  float rValue2 = 0;
  if(enemyDead2)
  {
    RandomEvent();
    rValue2 = RandomValue;
    difference2 = millis()/ 1000;
    enemyDead2 = false;
  }
  else
  {
    for(int i = 0; i < rValue2 ;i++)
    {
      fill(0);
      noStroke();
      rect(Random[i]/10.0 * width, 150 * (time2), RECT_SIZE_WIDTH, RECT_SIZE_HEIGHT);
    }
//  text(time/1000.0, 50, 100);
    if(50 * (time2) + 3 * RECT_SIZE_HEIGHT >= height)
    {
      enemyDead2 = true;
    }
    for(int i = 0; i < rValue2; i++)
    {
      if((Random[i]/10.0 * width <= playerX)&&(playerX <= Random[i]/10.0 * width + RECT_SIZE_WIDTH) && (playerY <= 100 * (time2) + RECT_SIZE_HEIGHT) && (playerY >= 100 * (time2)))
      {
        gameover = true;
      }
    }
    if(gameover)
    {
      GameOver();
    }
  }
  }
  */
////////////////////////////////
  //point
    for(int i = 1; i < 9; i++)
    {
      if(number[i - 1] == 1 && number [i + 1] == 1 && number[i] == 0)
      {
        if(playerX/50 == i)
        {
          if(playerY <= 150 * (time + 1))
          {
            get[i] = true;
          }
        }
        if(!get[i])
      {
        fill(255,255,0);
        circle(float(i) / 10 * width + RECT_SIZE_WIDTH/2, 150 * time + RECT_SIZE_HEIGHT /2, 25);
      }
      }
    }
    
    for(int i = 0; i < 10; i++)
    {
      get[i] = false;
    }
    
  if(playerX > 40 && playerX < 450)
  {
    for(int i = 0; i < 8; i++)
    {
      if(playerX/50 != 0 && playerX/50 != 9)
      {
        if(number[playerX/50 - 1] == 1 && number [playerX/50 + 1] == 1)
        {  
          if(playerY <= 150 * (time - 1))
          {
            through = true;
          }
        }
      }
    }
    for(int i = 0; i < 10; i++)
    {
      number[i] = 0;
    }
  }
  
  if(through)
  {
    point += 50;
    through = false;
    textSize(20);
    fill(255,0,0);
    text("+50p", 100, 250);
  }
  fill(0);
  textSize(20);
  text("point", 50, 230);
  text(str(point), 50, 250);
  }
}

public void Second()
{
  while(start_time - clear_time <= 1000)
  {
    start_time = millis();
    second_stage = true;
    first_stage = false;
    background(0);
    fill(255, 0, 0);
    textSize(width / 10);
    text("FIRST STAGE CLEAR", 3 * width / 10, height / 2);
    println(start_time - clear_time);
  }
  SecondStart();
}

public void SecondStart() 
{
  while(finish_time - start_time <= 1000)
  {
    finish_time = millis();
    background(0);    
    textSize(width / 10);
    text("NEXT STAGE", 3 * width / 10, height / 2);
    point = 0; 
    println(finish_time - start_time);
  }
}

public void RandomEvent()
{
  RandomValue = random(6, 8);
  for (int count = 0;count < RandomValue; count++){
    Random[count] = int(random(10));
  }
}

public void GameOver()
{
  background(0);
  fill(255, 0, 0);
  textSize(width / 10);
  text("CRASH!", 3 * width / 10, height / 2);
  delay(2000);
  exit();
}

void serialEvent(Serial sp){
  if(sp.available() > 0){
    byte[] inbuf = new byte[8];
    sp.readBytes(inbuf);
    message = new String(inbuf);
    if(inbuf[0] == 65){
        playerMoveRight = "A";
        serialPort.write("1");
    }
    if(inbuf[0] == 66){
        playerMoveRight = "B";
        serialPort.write("2");
    }
    if(inbuf[0] == 67)
    {
        playerMoveRight = "C";
        serialPort.write("3");
    }
   println(inbuf[0]);
  // println(message);
  }
}
