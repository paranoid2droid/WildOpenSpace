// PongView   Silly balls and pegs on black background
//     by Perry R. Cook     July 2015
//        hacked/improved Aug 2015, multiple balls and pegs (same really)
//        further hacked/improved:  color!!
//        AND...  Hearts!!! AND Triangles (filled) AND Deltas (unfilled)<3
//	  AND boXes (filled) AND Rectangles (unfilled)
//	Aug 15:   re-architect.  One polymorphic object container
//      Aug 28: ADDED Ellipses and Drums!
#ifdef OSX
// Use these includes for Mac OS X:
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <GLUT/glut.h>
#else
// Use these includes for LINUX and Windoze:
#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glut.h>
#endif

#include <string.h>
#include <stdlib.h>



#include <string.h>
#include <stdlib.h>

#include <unistd.h>
// #include <pthread.h>

#include <stdio.h>
#include <math.h>
#include <string.h>

#define MAX_OBJ 200

int myWin;

#define X_MAX 500
#define Y_MAX 500

int numStrings = 0;
int notDone = 1;
int outOne = 0;
#define STRING_LEN 1024
#define MAX_IN_STRINGS 128
#define TWO_PI 6.28

char inputString[MAX_IN_STRINGS][STRING_LEN];

// The input command pipe and socket threads are defined here.
#include "threads.h"

unsigned long string_thread;

struct GraphicsObject {
	char type;
	int fill;
	float x;
	float y;
	float r;
	float x2;
	float y2;
	float x3;
	float y3;
	float red;
	float green;
	float blue;
};

struct GraphicsObject gobj[MAX_OBJ];

int it;
float arg1, arg2, arg3, arg4, arg5, arg6;

void printAll();

void newStringByPipe(void)	{
  extern int numStrings, notDone;
  char tempString[256];
  int i,temp,gotOne;
  int inOne = 0;

  while (notDone) {
    fgets(inputString[inOne],STRING_LEN,stdin);
	if (inputString[inOne][2] == 'i' && inputString[inOne][3] == 't'
        	&& inputString[inOne][1] == 'x' && inputString[inOne][0] == 'E') {
      		notDone = 0;
       		printf("Exit!  Done PongViewing!!\n");
	   	glutDestroyWindow(myWin);
	   	exit(0);
    	}
    	else {
	    numStrings++;
	    inOne++;
	    if (inOne == MAX_IN_STRINGS) inOne = 0;
      	    while (numStrings > 0)	{
    		if (inputString[outOne][0] == '/') {  // comment
		    printf("%s \n", inputString[outOne][0]);
		    fflush(stdout);
		}
		else	{
		    sscanf(&inputString[outOne][1], "%i", &it);
		    if (it < MAX_OBJ)  {
			char type = inputString[outOne][0];
  	        	sscanf(&inputString[outOne][3],"%f %f %f %f %f %f",&arg1,&arg2,&arg3,&arg4,&arg5,&arg6);
			if (type == 'c') { gobj[it].red = arg1; gobj[it].green = arg2; gobj[it].blue = arg3; } // color for object
		        else if (type == 'p') { printAll(); } // print all current active displayed objects
		        else if (type == 'f') { gobj[it].fill = (int) arg1; } // fill = 1.0, not = 0.0
		        else if (type == '-') { gobj[it].type = 0; } // disable (remove) object from drawing pool
			else {
			         if (type == 'b') { gobj[it].type = type; gobj[it].x = arg1; gobj[it].y = arg2; gobj[it].r = arg3; } // ball (circle)
			    else if (type == 'e') { gobj[it].type = type; gobj[it].x = arg1; gobj[it].y = arg2; 
							gobj[it].x2 = arg3; gobj[it].y2 = arg4; }				     // ellipse
			    else if (type == 'h') { gobj[it].type = type; gobj[it].x = arg1; gobj[it].y = arg2; gobj[it].r = arg3; } // heart
			    else if (type == 'u') { gobj[it].type = type; gobj[it].x = arg1; gobj[it].y = arg2; gobj[it].r = arg3; } // club
			    else if (type == 's') { gobj[it].type = type; gobj[it].x = arg1; gobj[it].y = arg2; gobj[it].r = arg3; } // spade
			    else if (type == 'd') { gobj[it].type = type; gobj[it].x = arg1; gobj[it].y = arg2; 
							gobj[it].x2 = arg3; gobj[it].y2 = arg4; } 				     // diamond
			    else if (type == 'l') { gobj[it].type = type; gobj[it].x = arg1; gobj[it].y = arg2; 
							gobj[it].x2 = arg3; gobj[it].y2 = arg4; } 				     // line
			    else if (type == 'r') { gobj[it].type = type; gobj[it].x = arg1; gobj[it].y = arg2; 
							gobj[it].x2 = arg3; gobj[it].y2 = arg4; } 				     // rectangle
			    else if (type == 't') { gobj[it].type = type; gobj[it].x = arg1; gobj[it].y = arg2; gobj[it].x2 = arg3; 
						    gobj[it].y2 = arg4; gobj[it].x3 = arg5; gobj[it].y3 = arg6; } 		     // triangle
			}
		    }
		}
	        outOne += 1;
	        if (outOne == MAX_IN_STRINGS) outOne = 0;
		numStrings -= 1;
	    }
//	    printf("%f %f \n",xloc,yloc);
  	    glutSetWindow(myWin);
	    glutPostRedisplay();
    	}
   }

   pthread_cancel(string_thread);
   pthread_join(string_thread, NULL);

//  _endthread();
}

void printAll()  {
   for (int i=0; i<MAX_OBJ; i++)  {
	struct GraphicsObject gfx = gobj[i];
	char type = gfx.type;
	if (type)  {
	  printf("Object%i: ",i);
	  if (gfx.fill) printf("FILL   "); else printf("NOFILL ");
	  printf("red=%3.2f grn=%3.2f blu=%3.2f ",gfx.red,gfx.green,gfx.blue);
	  if (type == 'b') { // ball (circle)
	    printf("Ball    %3.2f %3.2f %3.2f ",gfx.x,gfx.y,gfx.r);
	  }
	  else if (type == 'e') { // ellipse
	    printf("Ellipse %3.2f %3.2f %3.2f %3.2f ",gfx.x,gfx.y,gfx.x2,gfx.y2);
	  }
	  else if (type == 'h') { // heart
	    printf("Heart   %3.2f %3.2f %3.2f ",gfx.x,gfx.y,gfx.r);
	  }
	  else if (type == 'u') { // club
	    printf("Club    %3.2f %3.2f %3.2f ",gfx.x,gfx.y,gfx.r);
	  }
	  else if (type == 's') { // spade
	    printf("Spade   %3.2f %3.2f %3.2f ",gfx.x,gfx.y,gfx.r);
	  }
	  else if (type == 'd') { // diamond
	    printf("Diamond %3.2f %3.2f %3.2f ",gfx.x,gfx.y,gfx.r);
	  }
	  else if (type == 'l') { // line
	    printf("Diamond %3.2f %3.2f %3.2f %3.2f",gfx.x,gfx.y,gfx.x2,gfx.y2);
	  }
	  else if (type == 'r') { // rectangle
	    printf("Rectang %3.2f %3.2f %3.2f %3.2f",gfx.x,gfx.y,gfx.x2,gfx.y2);
	  }
	  else if (type == 't') { // triangle
	    printf("Triangl %3.2f %3.2f %3.2f %3.2f %3.2f %3.2f",gfx.x,gfx.y,gfx.x2,gfx.y2,gfx.x3,gfx.y3);
	  }
	  printf("\n");
	}
    }
}

void startPipeThread()
{

//  string_thread = _beginthread(newStringByPipe, 0, NULL);
  if ( pthread_create(&string_thread, NULL, newStringByPipe, NULL) != 0 )  {
    fprintf(stderr, "unable to create input pipe thread ... aborting.\n");
    exit(0);
  }
}

float sine[65],cosine[65];

void ellipse(float x, float y, float w, float h)
{
        int i;
        float xD,yD,xDl,yDl;
        float del = (h - w);

        glBegin(GL_LINES);
        xDl = x + w;
        yDl = y;
        for (i=1;i<=64;i++)     {
          xD = x + w * cosine[i];
          yD = y + h * sine[i];
	  glVertex2f(xD, yD);
	  glVertex2f(xDl, yDl);
          xDl = xD;
          yDl = yD;
        }
        glEnd();
}

void ellipseFill(float x, float y, float w, float h)  {
        int i;
        float xD,yD,xDl,yDl;

	glBegin(GL_TRIANGLE_FAN);
        xDl = x + w;
        yDl = y;
        for (i=1;i<=64;i++)     {
          xD = x + w * cosine[i];
          yD = y + h * sine[i];
	  glVertex2f(xD, yD);
	  glVertex2f(xDl, yDl);
          xDl = xD;
          yDl = yD;
        }
        glEnd();
}

void circle(float x, float y, float r)
{
    ellipse(x,y,r,r);  // woohoo!!
}

void line(float x, float y, float x2, float y2)
{
        glBegin(GL_LINES);
	glVertex2f(x, y);
	glVertex2f(x2, y2);
        glEnd();
}

void circleFill(float x, float y, float r)
{
    ellipseFill(x,y,r,r);
}

void delta(float x1, float y1, float x2, float y2, float x3, float y3)  {
    glBegin(GL_LINES);
    glVertex2f(x1, y1);
    glVertex2f(x2, y2);
    glVertex2f(x2, y2);
    glVertex2f(x3, y3);
    glVertex2f(x3, y3);
    glVertex2f(x1, y1);
    glEnd();
}

void triangle(float x1, float y1, float x2, float y2, float x3, float y3)  {
    glBegin(GL_TRIANGLE_FAN);
    glVertex2f(x1, y1);
    glVertex2f(x2, y2);
    glVertex2f(x2, y2);
    glVertex2f(x3, y3);
    glVertex2f(x3, y3);
    glVertex2f(x1, y1);
    glEnd();
}

void rect(float x1, float y1, float x2, float y2)  {
    glBegin(GL_LINES);
    glVertex2f(x1, y1);
    glVertex2f(x2, y1);
    glVertex2f(x2, y1);
    glVertex2f(x2, y2);
    glVertex2f(x2, y2);
    glVertex2f(x1, y2);
    glVertex2f(x1, y2);
    glVertex2f(x1, y1);
    glEnd();
}

void rectFill(float x1, float y1, float x2, float y2)  {
    glBegin(GL_TRIANGLE_FAN);
    glVertex2f(x1, y1);
    glVertex2f(x2, y1);
    glVertex2f(x2, y2);
    glVertex2f(x1, y2);
    glVertex2f(x1, y1);
    glEnd();
}

void diamondFill(float x, float y, float w, float h)  {
    glBegin(GL_TRIANGLE_FAN);
    glVertex2f(x-w, y);
    glVertex2f(x, y-h);
    glVertex2f(x+w, y);
    glVertex2f(x, y+h);
    glVertex2f(x-w, y);
    glVertex2f(x-w, y);
    glEnd();
}

void diamond(float x, float y, float w, float h)  {
    glBegin(GL_TRIANGLE_FAN);
    line(x-w, y, x, y-h);
    line(x, y-h, x+w, y);
    line(x+w, y, x, y+h);
    line(x, y+h, x-w, y);
    line(x-w, y, x, y-h);
    glEnd();
}

void heart(float x, float y, float r)  {
    circle(x-0.45*r,y+r/3,r*0.5);
    circle(x+0.45*r,y+r/3,r*0.5);
    delta(x-0.88*r,y+0.1*r,x+0.88*r,y+0.1*r,x,y-1.1*r);
}

void heartFill(float x, float y, float r)  {
    circleFill(x-0.45*r,y+r/3,r*0.5);
    circleFill(x+0.45*r,y+r/3,r*0.5);
    triangle(x-0.88*r,y+0.1*r,x+0.88*r,y+0.1*r,x,y-1.1*r);
}

void club(float x, float y, float r)  {
    circle(x-r/2,y+0.1*r,r*0.4);
    circle(x+r/2,y+0.1*r,r*0.4);
    circle(x,y+r*0.6,r*0.4);
    delta(x-0.3*r,y-r,x+0.3*r,y-r,x,y+0.8*r);
}

void clubFill(float x, float y, float r)  {
    circleFill(x-r/2,y+0.1*r,r*0.4);
    circleFill(x+r/2,y+0.1*r,r*0.4);
    circleFill(x,y+r*0.6,r*0.4);
    triangle(x-0.3*r,y-r,x+0.3*r,y-r,x,y+r);
}

void spade(float x, float y, float r)  {
    circle(x-r/2,y-r*0.05,r*0.4);
    circle(x+r/2,y-r*0.05,r*0.4);
    delta(x-0.9*r,y+0.05*r,x+0.9*r,y+0.05*r,x,y+r);
    delta(x-0.3*r,y-r,x+0.3*r,y-r,x,y+r);
}

void spadeFill(float x, float y, float r)  {
    circleFill(x-r/2,y-r*0.05,r*0.4);
    circleFill(x+r/2,y-r*0.05,r*0.4);
    triangle(x-0.9*r,y+0.05*r,x+0.9*r,y+0.05*r,x,y+r);
    triangle(x-0.3*r,y-r,x+0.3*r,y-r,x,y+r);
}

void fullBox(float color)     {
        glColor3f(color,color,color);
        glRectf(-2.0,-2.0,2.0,2.0); // bigger than box (for rotations)
}

float frand(float min, float max) { // HACK
    return min + (max-min)*rand()/RAND_MAX;
}

void Redraw(void)	{
    fullBox(0.0);
//    glColor3f(1.0,1.0,1.0);
    for (int i=0;i<MAX_OBJ;i++) {
	struct GraphicsObject gfx = gobj[i];
	char type = gfx.type;
	glColor3f(gfx.red,gfx.green,gfx.blue);
	     if (type == 'b') { if (gfx.fill) circleFill(gfx.x,gfx.y,gfx.r); else circle(gfx.x,gfx.y,gfx.r); }	// ball (circle)
	else if (type == 'e') { if (gfx.fill) ellipseFill(gfx.x,gfx.y,gfx.x2,gfx.y2); 
				else ellipse(gfx.x,gfx.y,gfx.x2,gfx.y2); }   // note here center, width, height // ellipse
	else if (type == 'h') { if (gfx.fill) heartFill(gfx.x,gfx.y,gfx.r); else heart(gfx.x,gfx.y,gfx.r); }    // heart
	else if (type == 'u') { if (gfx.fill) clubFill(gfx.x,gfx.y,gfx.r); else club(gfx.x,gfx.y,gfx.r); }	// club
	else if (type == 's') { if (gfx.fill) spadeFill(gfx.x,gfx.y,gfx.r); else spade(gfx.x,gfx.y,gfx.r); }	// spade
	else if (type == 'd') { if (gfx.fill) diamondFill(gfx.x,gfx.y,gfx.x2,gfx.y2); 
				else diamond(gfx.x,gfx.y,gfx.x2,gfx.y2);}	// note here, x, y, w, h	// diamond
	else if (type == 'l') { line(gfx.x,gfx.y,gfx.x2,gfx.y2); }			// note here endpoints	// line
	else if (type == 'r') { if (gfx.fill) rectFill(gfx.x,gfx.y,gfx.x2,gfx.y2); 
				else rect(gfx.x,gfx.y,gfx.x2,gfx.y2); } 		// note here corners	// rectangle
	else if (type == 't') { if (gfx.fill) triangle(gfx.x,gfx.y,gfx.x2,gfx.y2,gfx.x3,gfx.y3); 
				else  delta(gfx.x,gfx.y,gfx.x2,gfx.y2,gfx.x3,gfx.y3); } // note here vertices	// triangle
    }
}

void IdleStub(void)	{   ;   }
void init(void)  {   glutPostRedisplay(); }

void display(void)	{
	Redraw();
	glutSwapBuffers();
}

void die(void)  {
    exit(0);  
}

void SpecialFunc(int key, int x, int y)
{
    if (key==0x1b)  {
	exit(0);
    }
    glutPostRedisplay();
}

void KeyFunc(unsigned char key, int x, int y)
{
    if (key==0x1b)  {
	exit(0);
    }
    glutPostRedisplay();
}

int main(int ac, char *av[]) {
    int i = 1;
    int iplus = 0;
    float scale = 1.0;
    float tempx, tempy;

// printf("%i %s\n",ac,av[1]);
    if (ac > 1)	{
	while (i < ac)  {
	    iplus = 0;
	    if (av[i][1]=='h') {
	        printf("useage: PongViewGL [-s scale] [-m] [-q] [-c] [-h]\n");
 	        exit(0);
	    }
	    i += iplus;
	}
    }

//	usleep(300000);  // optional if you want for other things to start first

    glutInit(&ac, av);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize(X_MAX*scale,Y_MAX*scale);
    glutInitWindowPosition(80,80);
    myWin = glutCreateWindow("Pong GL Viewer, 2015!!");
//    printf("%i \n",myWin);

    glutDisplayFunc(display);
    glutKeyboardFunc(KeyFunc);
    glutSpecialFunc(SpecialFunc);
    glutIdleFunc(IdleStub);
//    glutWMCloseFunc(die);

    glColor4f(0, 0, 0, 0);

    init();

    setbuf(stdin,NULL);
    startPipeThread();

/*   FOR REFERENCE
struct GraphicsObject {
	char type;
	int fill;
	float x;
	float y;
	float r;
	float x2;
	float y2;
	float x3;
	float y3;
	float red;
	float green;
	float blue;
}; */

    for (i=0;i<MAX_OBJ;i++) {
	gobj[i].type = 0; // null object, won’t draw
	gobj[i].x = -2.0; gobj[i].y = -2.0; // put it off screen at least 
	gobj[i].r = 0.0;  // and zero radius/size
	gobj[i].x2 = -2.0; gobj[i].y2 = -2.0; // put it off screen at least 
	gobj[i].x3 = -2.0; gobj[i].y3 = -2.0; // put it off screen at least 
	gobj[i].red = 1.0; gobj[i].green = 1.0; gobj[i].blue = 1.0;
    }

    for (i=0;i<65;i++)  { // reasonable resolution sine tables
	sine[i] = (float) sin(TWO_PI * (double) i / 64.0);
	cosine[i] = (float) cos(TWO_PI * (double) i / 64.0);
	tempx = sine[i]*sine[i];
	tempy = 0.1*cosine[i]*cosine[i];
    }
//    printf("\n");

    glutMainLoop();

    return 0;
}
