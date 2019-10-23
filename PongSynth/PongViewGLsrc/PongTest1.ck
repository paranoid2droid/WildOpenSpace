float x,y,rad;
float r,g,b;
string which;

while (true)   {
    Math.random2(0,7) => int pick;
    Math.random2(0,49) => int obj;
    chout <= "f"+Std.itoa(obj)+" "+Std.itoa(maybe)+"\n";
    chout.flush();
    ms => now;
    if (pick == 0)  {
	   "b"+obj => which;                // circle
    }
    else if (pick == 1) {
	   "h"+Math.random2(0,49) => which; // heart
    }
    if (pick == 2) {
	   "u"+Math.random2(0,49) => which; // cl<u>b
    }
    if (pick == 3) {
        "s"+Math.random2(0,49) => which; // spade
    }
    else if (pick == 4) {
	   "l"+Math.random2(0,49) => which; // line
    }
    else if (pick == 5) {
	   "r"+Math.random2(0,49) => which; // rectangle
    }
    else if (pick == 6) {
        "t"+Math.random2(0,49) => which; // triangle
    }
    else if (pick == 7) {
        "d"+Math.random2(0,49) => which; // diamond
    }
    Math.random2f(-1.0,1.0) => x;
    Math.random2f(-1.0,1.0) => y;
    Math.random2f(0.01,0.2) => rad;
    Math.random2f(0.0,1.0) => r;
    Math.random2f(0.0,1.0) => g;
    Math.random2f(0.0,1.0) => b;
    chout <= "c"+which+" "+Std.ftoa(r,3)+" "+Std.ftoa(g,3)+" "+Std.ftoa(b,3)+"\n";
    chout.flush();
    if (pick < 4)  {
    	chout <= which+" "+Std.ftoa(x,3)+" "+Std.ftoa(y,3)+" "+Std.ftoa(rad,3)+"\n";
    	chout.flush();
    }
    else {
	Math.random2f(-1.0,1.0) => float x2;
	Math.random2f(-1.0,1.0) => float y2;
	Math.random2f(-1.0,1.0) => float x3;
	Math.random2f(-1.0,1.0) => float y3;
	if (pick == 5) {
    	    chout <= which+" "+Std.ftoa(x,3)+" "+Std.ftoa(y,3)+" "+Std.ftoa(x2,3)+" "+Std.ftoa(y2,3)+"\n";
    	    chout.flush();	    
	}
	else if (pick == 6)  {
    	    chout <= which+" "+Std.ftoa(x,3)+" "+Std.ftoa(y,3)+" "+Std.ftoa(x2,3)+" "+Std.ftoa(y2,3)+" "+Std.ftoa(x3,3)+" "+Std.ftoa(y3,3)+"\n";
    	    chout.flush();
	}
	else if (pick == 7)  {
    	    chout <= which+" "+Std.ftoa(x,3)+" "+Std.ftoa(y,3)+" "+Std.ftoa(x2,3)+" "+Std.ftoa(y2,3)+" "+Std.ftoa(x3,3)+" "+Std.ftoa(y3,3)+"\n";
    	    chout.flush();
	}
    }
    10::ms => now;
}

chout <= "Exit\n";   // send exit signal to GL Viewer
chout.flush();

