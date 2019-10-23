// WILD OPEN SPACE
// by Zhe Zhang, december 2018
// based on the frame work of PONGView
// Generally speaking, it is a silly game which you use a phone as a remoter
// It collides, bounce and stop, making sounds

// declare a instance of the sound engine
SOUNDENGINE soundEngine => PRCRev rev => Pan2 pan => dac;
// starting reverb amount
0.1=> rev.mix;


class Ball {
    0.04 => float r;    // radius
    0.5 => float x;      // x position
    0.5 => float y;      // y position
    0.02 => float dx;    // velocity in x
    0.01 => float dy;    // velocity in y
    float ax,ay;         // acceleration in each direction
    0.99 => float damp; // 1.0 means no loss over time
}

// Bar will be graphic objects 20-34
class Bar {
    15 => int UNITS;
    -0.4 => float leftLoc; // leftmost point
    0.4 => float riteLoc;  // rightmost point
    float pnt[UNITS]; // points on bar
    float vel[UNITS]; // velocities
    0.99 => float damp;
}

// String will be graphic objects 35-66
class Strng {
    31 => int UNITS;
    float pnt[UNITS]; // points on string
    float vel[UNITS]; // velocities
    0.995 => float damp;
}

7 => int BALLS;  // Don't make TOO many of these... (N^2 collisions!)
                 // allocated graphics objects 0 - 18



//  Set up graphics objects here
Strng str;      // string animation object, objects 35-66
" 0.8 1.0 0.0\n" => string strc;  // string color

Bar bar;      // bar animation object, objects 20-34
" 0.8 0.0 1.0\n" => string barc;  // bar color

" 0.0 0.9 0.9\n" => string botc; // bottle color, objects 70+
drawBottle();  // uses primitives for drawing, objects

" 0.0 0.6 0.0\n" => string drmc; // drum color, objects 80+
drawDrum();   // uses primitives for drawing

Ball peg;  // rigid filled peg
0.0 => peg.x => peg.y => peg.dx => peg.dy;
0.05 => peg.r;
" 0.75 0.2 0.2\n" => string pegc;
drawPeg(19,peg);  // Graphics Object #19 is our peg

Ball ball[BALLS]; // moving, bouncing, balls!!

for (int i; i < BALLS; i++)  {
    0.05+flip()*3*i*ball[i].r => ball[i].x;
    0.05+flip()*3*i*ball[i].r => ball[i].y;
    Math.random2f(-0.02,0.02) => ball[i].dx;
    Math.random2f(-0.02,0.02) => ball[i].dy;
}

// OSC decalaration part
OscIn oin;        // make an OSC receiver
9000 => oin.port;  // set port #
oin.listenAll();  //   any message at all

OscMsg msg;   // message holder

// spork the OSC control function
spork ~ OscCtrl();
//  OK, now time to let the physics begin!
now + 120::second => time then;  // run for one minute

while (now < then)   {
    //<<< ball[0].x, ball[0].y, ball[0].dx, ball[0].dy >>>;
    for (int i; i < BALLS; i++)  {
        doBallPhysics(ball[i]);
        // All sounds are panned to where the ball is
        // left sound
        if (checkLeftWall(ball[i])) {
            ball[i].x => pan.pan;
            soundEngine.soundBall(i, ball[i].dx+ball[i].dy);
        }
        // string sound
        if (checkRiteString(ball[i])) {
            ball[i].x => pan.pan;
            soundEngine.soundBall(i, ball[i].dx+ball[i].dy);
            colorizeBall(i,strc);
            soundEngine.soundRight(ball[i].y, ball[i].dx);
        }
        // bottom wall sound
        if (checkBotWall(ball[i])) {
            ball[i].x => pan.pan;
            soundEngine.soundBall(i, ball[i].dy);
        }
        // top bar sound
        if (checkTopBar(ball[i],bar)) {
            ball[i].x => pan.pan;
            soundEngine.soundBall(i, ball[i].dx+ball[i].dy);
            soundEngine.soundTop( ball[i].x, ball[i].dx+ball[i].dy);
            colorizeBall(i,barc);
        }
        // top wall sound
        else if (checkTopWall(ball[i])) {
            ball[i].x => pan.pan;
            soundEngine.soundBall(i, ball[i].dx+ball[i].dy);
        }
        // drum sound
        if (checkBallDrumCollide(ball[i]))  {
            ball[i].x => pan.pan;
            soundEngine.soundBall(i, ball[i].dx+ball[i].dy);
            soundEngine.soundBot(ball[i].dx+ball[i].dy, 10*(ball[i].dx+ball[i].dy));
            colorizeBall(i,drmc);
        }
        // bottle sound
        if (checkBallBottleCollide(ball[i]))  {
            ball[i].x => pan.pan;
            soundEngine.soundBall(i, ball[i].dx+ball[i].dy);
            soundEngine.soundLeft(i, ball[i].dx+ball[i].dy);
            colorizeBall(i,botc);
        }
        // when ball hits the peg
        // the time "freezes" while the reverb amout is lager and lager
        // untill it is totally wet
        if (checkBallPegCollide(ball[i],peg))  {
            colorizeBall(i,pegc);
            0 => float temp => rev.mix;
            while( temp < 0.98 ){
                0.02::second => now;
                0.02 +=> temp;
                temp => rev.mix;
            }
            0 => rev.mix;
        }
        for (i+1 => int j; j < BALLS; j++)  {
            if (checkBallBallCollide(ball[i],ball[j]))  {
                ball[j].x => pan.pan;
                soundEngine.soundBall(i, ball[i].dy+ball[i].dy);
                soundEngine.soundBall(j, ball[j].dy+ball[j].dx);
            }
            // do safety check to see if they're (still) stuck together
            if (distance(ball[i],ball[j]) < ball[i].r)  {
                Math.random2f(-0.9,0.9) => ball[i].x;
                Math.random2f(-0.9,0.9) => ball[i].y;
            }
        }
        drawBall(i,ball[i]);
        ms => now;
    }
    doBarPhysics(bar);
    drawBar(bar);
    doStrngPhysics(str);
    drawStrng(str);
    (33-BALLS-(bar.UNITS/2))*ms => now;  // 30 frames (roughly) per second
}

chout <= "Exit\n";   // send exit signal to GL Viewer
chout.flush();

fun int flip()  {
    if (maybe) return 1;
    else return -1;
}

fun void bounceOffX(Ball bl)  {
    2*bl.dx -=> bl.x;  // bounce off
    -0.8 *=> bl.dx;   // with velocity reflection
    //Math.random2f(-0.001,0.001) => bl.ax;  // new random x force    
}

fun int checkLeftWall(Ball bl)  {
    if (bl.x < -(1.0-bl.r)) {  // check left limit in x
        bounceOffX(bl);
        return 1;
    }
    else return 0;
}
    
fun int checkRiteString(Ball bl)  {
    Std.ftoi(0.5 * (1.0+bl.y) * str.UNITS) => int strElement;
    // just in case some ball has wandered too far
    if (strElement >= str.UNITS) str.UNITS-1 => strElement;
    if (bl.x > (0.9+str.pnt[strElement])) {  // check right limit in x
        bl.dx => float temp;
        (0.9+str.pnt[strElement]) - 3*Math.fabs(bl.dx) => bl.x;  // bounce off
        str.vel[strElement] => bl.dx;
        //       -1 *=> bl.dx;   // with velocity reflection
        temp => str.vel[strElement];
        //Math.random2f(-0.002,0.0) => bl.ax;  // new random y force (down)
//        kstrng.pluck(40+strElement,temp);  // would NEED THIS!!
        return 1;
    }
    else return 0;
}
    
fun void bounceOffY(Ball bl)  {
    2*bl.dy -=> bl.y;  // bounce off
    -0.8 *=> bl.dy;   // with velocity reflection
    Math.random2f(-0.001,0.001) => bl.ay;  // new random y force
}

fun int checkTopWall(Ball bl)  {
    if (bl.y > (1.0-bl.r)) {  // check top limit in y
        bounceOffY(bl);
        return 1;
    }
    else return 0;
}

fun int checkTopBar(Ball bl, Bar br)  {
    if (bl.x >= br.leftLoc && bl.x <= br.riteLoc)  {
        Std.ftoi((bl.x - br.leftLoc) / (br.riteLoc-br.leftLoc) * br.UNITS) => int barElement;
        if (bl.y > (0.9+br.pnt[barElement])) {  // check top limit in y

            (0.9+br.pnt[barElement]) - 3*Math.fabs(bl.dy) => bl.y;  // bounce off
            br.vel[barElement] => bl.dy;

            Math.random2f(-0.002,0.0) => bl.ay;  // new random y force (down)
            return 1;
        }
        else return 0;
    }
    else return 0;
}

fun int checkBotWall(Ball bl)  {
    if (bl.y < -(1.0-bl.r)) {  // check top limit in y
        bounceOffY(bl);
        return 1;
    }
    else return 0;
}

fun float distance(Ball bl, Ball bl2)  {
    bl2.x - bl.x => float delx;
    bl2.y - bl.y => float dely;
    return Math.sqrt(delx*delx + dely*dely);
}

fun int checkBallPegCollide(Ball bl, Ball pg)  {
    if (distance(bl,pg) < pg.r)  {  // collision!!
        2*bl.dy -=> bl.y;  // bounce off
        -0.5 *=> bl.dy;   // with velocity reflection and great loss
        2*bl.dx -=> bl.x;  // bounce off
        -0.5 *=> bl.dx;   // with velocity reflection and great loss
        // the peg has magical powers!!!
        //Math.random2f(-0.001,0.001) => bl.ax; // new random forces
        //Math.random2f(-0.001,0.001) => bl.ay; //  after collision
        return 1;
    }
    else return 0;
}

fun int checkBallDrumCollide(Ball bl)  {
    if (bl.y < -0.75 && bl.x > -0.25 && bl.x < 0.25)  {
        2*bl.dy -=> bl.y;  // bounce off
        -0.5 *=> bl.dy;   // with velocity reflection and great loss
        2*bl.dx -=> bl.x;  // bounce off
        flip()*0.5 *=> bl.dx;   // with random velocity reflection and great loss        
        // the drum has magical powers!!!
        //Math.random2f(-0.001,0.001) => bl.ax; // new random forces
        //Math.random2f(-0.001,0.001) => bl.ay; //  after collision
        return 1;
    }
    else return 0;
}

fun int checkBallBottleCollide(Ball bl)  {
    if (bl.x < -0.8 && bl.y < 0.1 && bl.y > -0.4) {
        2*bl.dy -=> bl.y;  // bounce off
        flip()*0.5 *=> bl.dy;   // with random velocity reflection and great loss
        3*bl.dx -=> bl.x;  // bounce off
        -0.73 *=> bl.dx;   // with velocity reflection and great loss        
        return 1;
    }
    else return 0;
}

fun int checkBallBallCollide(Ball bl1, Ball bl2)  {
    if (distance(bl2,bl1) < bl1.r+bl2.r)  {  // collision!!
        1*bl1.dy -=> bl1.y;  // bounce off a lot to help
        1*bl2.dy -=> bl2.y;  // avoid sticking
        bl2.dy => float temp;    // exchange velocities
        bl1.dy => bl2.dy;   // at collision
        temp => bl1.dy;
        
        2*bl1.dx -=> bl1.x;  // bounce off a lot to help
        2*bl2.dx -=> bl2.x;  // avoid sticking
        bl2.dx => temp;    // exchange velocities
        bl1.dx => bl2.dx;   // at collision
        temp => bl1.dx;
        return 1;
    }
    else return 0;
}

fun void doBallPhysics(Ball bl)  {
    bl.ax +=> bl.dx;   // dx += ax; // in C/Java
    bl.ay +=> bl.dy;   // dy += ay; // in C/Java
    (bl.damp *=> bl.dx) +=> bl.x;      // x += (dx *= damp);  // in C/Java
    (bl.damp *=> bl.dy) +=> bl.y;      // y += (dy *= damp);  // in C/Java
}


// Graphics Stuff
fun void drawBottle()  { // bounds: less than -0.8x, y between 0.1 -0.4
// Bottle graphics objects 70-73
    chout <= "h70 -0.9 0.0 0.07\n"; chout.flush();
    chout <= "e71 -0.9 -0.2 0.08 0.20\n"; chout.flush();
    chout <= "r72 -0.98 -0.4 -0.82 -0.15\n"; chout.flush();
    chout <= "r73 -0.96 -0.39 -0.84 -0.10\n"; chout.flush();
    chout <= "f70 1\n"; chout.flush();
    chout <= "f71 1\n"; chout.flush();
    chout <= "f72 1\n"; chout.flush();
    chout <= "f73 1\n"; chout.flush();
    chout <= "c70 0 0.9 0.9\n"; chout.flush();
    chout <= "c71 0 0.9 0.9\n"; chout.flush();
    chout <= "c72 0 0.9 0.9\n"; chout.flush();
    chout <= "c73 0 0.7 0.7\n"; chout.flush();
}

fun void drawDrum()  {  // bounds: -0.2x to 0.2x and less than -0.8y
// Drum graphics objects 80-87
    chout <= "e80 0 -0.8 0.2 0.05\n"; chout.flush();
    chout <= "f80 1\n"; chout.flush();
    chout <= "e81 0 -0.95 0.2 0.05\n"; chout.flush();
    chout <= "l82 -0.2 -0.8 -0.2 -0.95\n"; chout.flush();
    chout <= "l83 0.2 -0.8 0.2 -0.95\n"; chout.flush();
    chout <= "l84 -0.2 -0.8 -0.1 -0.99\n"; chout.flush();
    chout <= "l85 0.2 -0.8 0.1 -0.99\n"; chout.flush();
    chout <= "l86 0.0 -0.85 -0.1 -0.99\n"; chout.flush();
    chout <= "l87 0.0 -0.85 0.1 -0.99\n"; chout.flush();
    chout <= "c80 0 0.6 0\n"; chout.flush();
}

fun void drawBall(int which, Ball bl)  {
    chout <= "b"+which+" "+bl.x+" "+bl.y+" "+bl.r+"\n";   // draw a ball
    chout.flush();                  // make sure things don't linger in buffers
}

fun void drawPeg(int which, Ball pg)  {
    drawBall(which,pg);        // draw a ball
    chout <= "f"+which+" 1\n"; // then fill it in
    chout.flush();
    chout <= "c"+which+pegc;
    chout.flush();
}

fun void colorizeBall(int which, string color)  {
    chout <= "c"+which+" "+color;
    chout.flush();
    chout <= "f"+which+" 1\n";
    chout.flush();
}

fun void drawBar(Bar bar)  {
// Bar graphics objects begin at 20
    20 => int BARGRPH;
    (bar.riteLoc - bar.leftLoc) / (bar.UNITS-1) => float del;
    for (0 => int i; i < bar.UNITS-1; i++)  {
        bar.leftLoc + i*del => float x;
        x + del => float x2;
        bar.pnt[i]/2 => float y;  // more rigid
        bar.pnt[i+1]/2 => float y2;
        chout <= "l"+(i+BARGRPH)+" "+x+" "+(0.9+y)+" "+x2+" "+(0.9+y2)+"\n";   // draw a line
        chout.flush();                  // make sure things don't linger in buffers
        chout <= "c"+(i+BARGRPH)+barc;
        chout.flush();
        ms/2 => now;
    }
}

fun void doBarPhysics(Bar br)  {
    // basic newtonian stuff, plus some extra loss
    for (1 => int i; i < br.UNITS-1; i++)  {
        // calculate curvature at each point, that's acceleration
        br.pnt[i+1]-2*br.pnt[i]+br.pnt[i-1] => float acc; 
        acc*0.2 +=> br.vel[i]; // update velocities
    }
    for (1 => int i; i < br.UNITS-1; i++)  {
        br.vel[i] +=> br.pnt[i]; // update positions
        br.damp *=> br.pnt[i];  // position "damping" decay
        br.damp *=> br.vel[i];  // velocity damping
    }
}

fun void drawStrng(Strng str)  {
    35 => int STRGRPH;  // String graphics objects begin at 35
    2.0 / (str.UNITS-1) => float del;
    for (0 => int i; i < str.UNITS-1; i++)  {
        -1.0 + i*del => float y;
        y + del => float y2;
        0.9+str.pnt[i] => float x;
        0.9+str.pnt[i+1] => float x2;
        chout <= "l"+(i+STRGRPH)+" "+x+" "+y+" "+x2+" "+y2+"\n";   // draw a line
        chout.flush();                  // make sure things don't linger in buffers
        chout <= "c"+(i+STRGRPH)+strc;
        chout.flush();
        ms/2 => now;
    }
}

fun void doStrngPhysics(Strng str)  {
    // basic newtonian stuff, plus some extra loss
    for (1 => int i; i < str.UNITS-1; i++)  {
        // calculate curvature at each point, that's acceleration
        str.pnt[i+1]-2*str.pnt[i]+str.pnt[i-1] => float acc; 
        acc*0.1 +=> str.vel[i]; // update velocities
    }
    for (1 => int i; i < str.UNITS-1; i++)  {
        str.vel[i] +=> str.pnt[i]; // update positions
        str.damp *=> str.pnt[i];  // position "damping" decay
        str.damp *=> str.vel[i];  // velocity damping
    }
}

// OSC control
fun void OscCtrl(){
    while(true){
        oin => now;   // wait for any OSC
    
        while(oin.recv(msg))
        {
           // <<< "got message:", msg.address, msg.typetag >>>;
            // first finger on the xy pad
            if( msg.address == "/1/multixy/1" ){
                msg.getFloat(0) => float ptr_1_x;
                msg.getFloat(1) => float ptr_1_y;
                Math.sqrt( ptr_1_x*ptr_1_x + ptr_1_y*ptr_1_y ) => float d1;
                //<<< "got message:", msg.address, ptr_1_x, ptr_1_y, d1 >>>;
                // give a force from where the finger is
                for( 0 => int i; i < BALLS; i++ ){
                    (ptr_1_x - ball[i].x)/d1*0.00001 +=> ball[i].ax;
                    (ptr_1_y - ball[i].y)/d1*0.00001 +=> ball[i].ay;
                }            
            }
            // forces releases when finger releases
            else if( msg.address == "/1/multixy/1/z" ){
                <<< "got message:", msg.address, msg.getFloat(0) >>>;
                if( msg.getFloat(0) == 0 ){
                    for( 0 => int i; i < BALLS; i++ ){
                        0 => ball[i].ax;
                        0 => ball[i].ay;
                    }
                }  
            }
            // a second finger on the pad
            if( msg.address == "/1/multixy/2" ){
                msg.getFloat(0) => float ptr_2_x;
                msg.getFloat(1) => float ptr_2_y;
                Math.sqrt( ptr_2_x*ptr_2_x + ptr_2_y*ptr_2_y ) => float d2;
                <<< "got message:", msg.address, ptr_2_x, ptr_2_y, d2 >>>;
                for( 0 => int i; i < BALLS; i++ ){
                    (ptr_2_x - ball[i].x)/d2*0.00001 +=> ball[i].ax;
                    (ptr_2_y - ball[i].y)/d2*0.00001 +=> ball[i].ay;
                }       
            }
            else if( msg.address == "/1/multixy/2/z" ){
                <<< "got message:", msg.address, msg.getFloat(0) >>>;
                if( msg.getFloat(0) == 0 ){
                    for( 0 => int i; i < BALLS; i++ ){
                        0 => ball[i].ax;
                        0 => ball[i].ay;
                    }
                }  
            }
            // support 3 fingers at most
            if( msg.address == "/1/multixy/3" ){
                msg.getFloat(0) => float ptr_3_x;
                msg.getFloat(1) => float ptr_3_y;
                Math.sqrt( ptr_3_x*ptr_3_x + ptr_3_y*ptr_3_y ) => float d3;
                <<< "got message:", msg.address, ptr_3_x, ptr_3_y, d3 >>>;
                for( 0 => int i; i < BALLS; i++ ){
                    (ptr_3_x - ball[i].x)/d3*0.00001 +=> ball[i].ax;
                    (ptr_3_y - ball[i].y)/d3*0.00001 +=> ball[i].ay;
                }       
            }
            else if( msg.address == "/1/multixy/3/z" ){
                <<< "got message:", msg.address, msg.getFloat(0) >>>;
                if( msg.getFloat(0) == 0 ){
                    for( 0 => int i; i < BALLS; i++ ){
                        0 => ball[i].ax;
                        0 => ball[i].ay;
                    }
                }  
            }
            // the rotary for the damping in the space
            if( msg.address == "/1/rotary" ){
                msg.getFloat(0) => float knobvalue;
                <<< "got message:", msg.address, knobvalue >>>;
                for( 0 => int i; i < BALLS; i++ ){
                    // make the knob move smoothly
                    1 - (knobvalue-1)*(knobvalue-1) => ball[i].damp;
                    // also the bigger the damping, the lager the reverb
                    1 - knobvalue*knobvalue => rev.mix;
                }   
            }
            // right button for stop the balls
            if( msg.address == "/1/pushR" ){
                msg.getFloat(0) => float pushR;
                <<< "got message:", msg.address, pushR >>>;
                if(pushR == 1){
                    // velocities are set to 0
                    for( 0 => int i; i < BALLS; i++ ){
                        0.0 => ball[i].dx;
                        0.0 => ball[i].dy;
                    }
                }
                if(pushR == 0){
                // wait to add new features
                }
            }
            // left button for give random velocities
            if( msg.address == "/1/pushL" ){
                msg.getFloat(0) => float pushL;
                <<< "got message:", msg.address, pushL >>>;
                if(pushL == 1){
                    for( 0 => int i; i < BALLS; i++ ){
                        Math.random2f(-0.11, 0.11) => ball[i].dx;
                        Math.random2f(-0.11, 0.11) => ball[i].dy;
                    }
                }
                if(pushL == 0){
                // wait to add new features
                }
            }  
            
        }
    }
}