// ChuckSound.ck
// this is the sound engine of the game

public class SOUNDENGINE extends Chubgraph{
    // unit generators and stks used
    // Banded wave guide models for balls
    BandedWG bwg => Dyno comp1 => outlet;
    // PercFlut for the bottle
    PercFlut pfl => Dyno comp2 => outlet;
    // Two mandolins for the string
    Mandolin mdl1 => Dyno comp3 => outlet;
    Mandolin mdl2 => comp3 => outlet;
    // SinOscs for the bar
    SinOsc sin[3];
    NRev N => Dyno comp4 => outlet;
    for( 0 => int i; i < 3; i++ ){
        .2 => sin[i].gain;
        sin[i] => N;
    }
    // shakers for the drum
    Shakers skr => Echo eco => Dyno comp5 => outlet;
    .73 => eco.mix;
    // limiters inserted to every channel
    comp1.limit();
    comp2.limit();
    comp3.limit();
    comp4.limit();
    comp5.limit();
    
    // ball-ball collision sound
    fun void soundBall(int which, float vel){
        // every ball has its own sound
        which => bwg.preset;
        Math.random2f(100,1500) => bwg.freq;
        100*vel => bwg.noteOn;
    }
    // the bottle sound
    fun void soundLeft(int pitch, float vel){
        72+pitch => Std.mtof => pfl.freq;
        0.42 + 9*vel => pfl.noteOn;
    }
    // string sound
    fun void soundRight(float pitch, float vel){
        60+24*pitch => Std.fabs => Std.mtof => mdl1.freq;
        60-24*pitch => Std.fabs => Std.mtof => mdl2.freq;
        0.22 + 0.73*vel => float temp;
        if( temp > 0.9) 0.9 => temp;
        temp => mdl1.noteOn;
        temp => mdl2.noteOn;
    }
    // bar sound
    fun void soundTop(float freq, float rev){
        42 + freq * 1000 => float temp;
        temp/1.5 => Std.fabs => sin[0].freq;
        temp => Std.fabs => sin[1].freq;
        temp*1.5 => Std.fabs => sin[2].freq;
        10*rev => Std.fabs => N.mix;
    }
    // the drum sound
    fun void soundBot(float obj, float dec){
        Math.random2(0, 22) => skr.preset;
        42+100*obj => float temp;
        if( temp > 128 ) 128 => temp;
        temp => skr.objects; // 0 - 128
        .42 + Std.fabs(dec) => temp;
        if( temp > 1 ) 1 => temp;
        temp => skr.decay; // 0 - 1
        1 => skr.noteOn;
    }    
}
    

