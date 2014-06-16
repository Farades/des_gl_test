module kiapp;

import std.algorithm;
import std.array;
import std.stdio;
import std.math;

import desutil;
import desmath;

import app;
import draw;

class KiApp : GLApp, ExternalMemoryManager
{
    mixin( getMixinChildEMM() );
    protected void selfDestroy() {}

private:
    MCamera camera;

    DrawPlane comp_skel;

    vec3 camvec = vec3( 0, 0, 10 );

    void rotateCamera( vec2 angles )
    {
        auto xrot = quat.fromAngle( angles.x, vec3( 0, 1, 0 ) );
        auto yrot = quat.fromAngle( angles.y, ( vec3( 0, 1, 0 ) * camvec ).e );
        camvec = (xrot*yrot).rot(camvec);
        updateCamera();
    }

    void updateCamera()
    { camera.look( camvec, vec3( 0, 0, 0 ), vec3( 0, 1, 0 ) ); }

public:
    this()
    {
        comp_skel = registerChildEMM( new DrawPlane );

        camera = new MCamera; 
        updateCamera();
        comp_skel.setData();

        setIdleFunc(
        {
            
        });

        setKeyboardFunc( ( int Key, ushort Mod, uint unicode )
        {
            switch( Key )
            {
                case SDLK_ESCAPE: quit(); break;
                default: break;
            }
        });

        vec2 pvec;
        bool press_state = false;
        setMouseMoveFunc( (ivec2 mvec)
        {
             if( press_state )
             {
                vec2 dvec = mvec-pvec;
                rotateCamera( -dvec/100.0 );
             }
             pvec = mvec;
        });

        setMouseClickFunc( (ivec2 mvec, ubyte btn, ubyte st)
        {
            if( btn == 1 ) press_state = cast(bool)st;
        });

        auto wheel_zoom_coef = 0.5;
        setMouseWheelFunc( (int x, int y)
        {
            camvec -= camvec * y * wheel_zoom_coef; 
            if( camvec.len < 1 )
                camvec = camvec.e;
            updateCamera();
        });
        
        setDrawFunc( 
        {
            comp_skel.draw( camera );
        });
    }
}
