module draw.object;

public import desmath.linear;
public import desgl.base;

enum ShaderSource SS_BASE =
{
`#version 120
attribute vec3 pos;
attribute vec3 col;

uniform mat4 tr;

void main(void)
{
    gl_Position = tr * vec4( pos, 1.0 );
    gl_FrontColor = vec4( col, 1.0 );
}`
};

class DrawObject : GLObj, Node
{
protected:
    GLVBO pos;
    GLVBO col;
    CommonShaderProgram shader;
    bool needDraw = false;
    col4 color = col4(1,1,1,1);

    void predraw( Camera cam )
    {
        vao.bind();
        shader.use();
        shader.setUniformMat( "tr", cam(this) );
    }

    abstract void drawAlgo();

    Node par;

public:
    this()
    {
        shader = registerChildEMM( new CommonShaderProgram( SS_BASE ) );
        auto ploc = shader.getAttribLocation( "pos" );
        auto cloc = shader.getAttribLocation( "col" );
        pos = registerChildEMM( new GLVBO( [], GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW ) );
        col = registerChildEMM( new GLVBO( [], GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW ) );
        setAttribPointer( pos, ploc, 3, GL_FLOAT );
        setAttribPointer( col, cloc, 3, GL_FLOAT );
    }

    void draw( Camera cam )
    {
        if( !needDraw ) return;
        predraw( cam );
        drawAlgo();
    }

    override const @property
    {
        mat4 self() { return mat4(); }
        const(Node) parent() { return par; }
    }
}
