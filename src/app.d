module app;

import std.stdio;

public import derelict.sdl2.sdl;
public import derelict.opengl3.gl3;

public import desmath.linear.vector;
import desutil.helpers;

class GLAppException : Exception
{
    @safe pure nothrow this( string msg, string file = __FILE__, size_t line = __LINE__ )
    { super( msg, file, line ); }
}

class GLApp
{
private:
    SDL_Window *window = null;
    SDL_GLContext context;

    ivec2 sz;

    void delegate() didle = null;
    void delegate() ddraw;
    void delegate( ivec2 ) dmousemove;
    void delegate( ivec2, ubyte, ubyte ) dmouseclick;
    void delegate( int x, int y ) dmousewheel;
    void delegate( int, ushort, uint ) dkey;
    void delegate( ivec2 sz ) dresize;

    void idle()
    { 
        if( didle !is null )
            didle();
    }

    void draw()
    {
        glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
        if( ddraw !is null )
            ddraw();

        SDL_GL_SwapWindow( window );
    }

    void resize( ivec2 _sz )
    {
        sz = _sz;
        glViewport( 0, 0, sz.x, sz.y );
        if( dresize !is null )
            dresize( sz );
    }

public:
    this()
    {
        sz = sz_vec( 1600, 1200 );

        DerelictSDL2.load();
        DerelictGL3.load();

        if( SDL_Init( SDL_INIT_VIDEO ) < 0 )
            throw new GLAppException( "Error initializing SDL: " ~ toDString( SDL_GetError() ) );

        SDL_GL_SetAttribute( SDL_GL_BUFFER_SIZE, 32 );
        SDL_GL_SetAttribute( SDL_GL_DEPTH_SIZE, 24 );
        SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );
        SDL_WindowFlags flags = SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN;
        //if( set.get( "fullscreen", false ) )
        //    flags = flags | SDL_WINDOW_FULLSCREEN;
        //else
            flags = flags | SDL_WINDOW_RESIZABLE;
        import std.string;
        auto title = "App";
        window = SDL_CreateWindow( title.toStringz,
                                   SDL_WINDOWPOS_UNDEFINED,
                                   SDL_WINDOWPOS_UNDEFINED,
                                   sz.x, sz.y,
                                   flags );
        if( window is null )
            throw new GLAppException( "Couldn't create SDL widnow: " ~ toDString( SDL_GetError() ) );

        context = SDL_GL_CreateContext( window );

        if( context is null )
            throw new GLAppException( "Couldn't create GL context: " ~ toDString( SDL_GetError() ) );

        DerelictGL3.reload();

        glClearColor( 0.0, 0.0, 0.0, 0.0 );
        glViewport( 0, 0, sz.x, sz.y );
        glEnable( GL_BLEND );
        glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
        glEnable( GL_DEPTH_TEST );
        glDepthFunc( GL_LESS );
        glEnable(GL_PROGRAM_POINT_SIZE);
    }

    bool step()
    {
        SDL_Event ev;

        while( SDL_PollEvent( &ev ) )
        {
            ubyte state = 1;
            switch( ev.type )
            {
                /* Application events */
                case SDL_QUIT: return false;        /**< User-requested quit */

                /* Window events */
                case SDL_WINDOWEVENT:
                            if( ev.window.event == SDL_WINDOWEVENT_SIZE_CHANGED )
                                resize( ivec2( ev.window.data1, ev.window.data2 ) );
                            break;       /**< Window state change */

                case SDL_SYSWMEVENT: break;        /**< System specific event */

                /* Keyboard events */
                case SDL_KEYDOWN: 
                            if( dkey !is null )
                                dkey( ev.key.keysym.sym, ev.key.keysym.mod, ev.key.keysym.unicode );
                            break;           /**< Key pressed */
                case SDL_KEYUP: break;             /**< Key released */
                case SDL_TEXTEDITING: break;       /**< Keyboard text editing (composition) */
                case SDL_TEXTINPUT: break;         /**< Keyboard text input */

                /* Mouse events */
                case SDL_MOUSEMOTION: 
                            if( dmousemove !is null )
                                dmousemove( ivec2(ev.motion.x, ev.motion.y ) );
                            break;       /**< Mouse moved */

                case SDL_MOUSEBUTTONUP:   state = 0; goto case; /**< Mouse button released */
                case SDL_MOUSEBUTTONDOWN: 
                            if( dmouseclick !is null )
                                dmouseclick( ivec2( ev.button.x, ev.button.y ), ev.button.button, state );
                            break;   /**< Mouse button pressed */

                case SDL_MOUSEWHEEL: 
                            if( dmousewheel !is null )
                                dmousewheel( ev.wheel.x, ev.wheel.y );
                            break;        /**< Mouse wheel motion */
                default: break;
            }
        }

        idle();

        draw();
        return true;
    }

    void run()
    {
        while( step() ) SDL_Delay(1);
        if( SDL_Quit !is null ) SDL_Quit();
    }

    void quit()
    {
        SDL_Event ev;
        ev.type = SDL_QUIT;
        SDL_PushEvent( &ev );
    }

    void setDrawFunc( void delegate() f ) { ddraw = f; }
    void setIdleFunc( void delegate() f ) { didle = f; }
    void setMouseMoveFunc( void delegate( ivec2 ) f ) { dmousemove = f; }
    void setMouseClickFunc( void delegate( ivec2, ubyte, ubyte ) f ) { dmouseclick = f; }
    void setMouseWheelFunc( void delegate( int, int ) f ) { dmousewheel = f; }
    void setKeyboardFunc( void delegate( int, ushort, uint ) f ) { dkey = f; }
    void setResizeFunc( void delegate( ivec2 ) f ) { dresize = f; }

    vec2 mapToScene( in ivec2 mp ) const
    {
        return vec2( (mp.x / cast(double)sz.x) * 2.0 - 1.0,
                    -(mp.y / cast(double)sz.y) * 2.0 + 1.0 );
    }

    @property ivec2 winsz() const { return sz; }
}
