module draw.skeleton;

import draw.object;

class DrawPlane : DrawObject
{
protected:
    int cnt;

    override void drawAlgo()
    {
        glLineWidth(3);
        glDrawArrays( GL_TRIANGLES, 0, cnt );
    }

    vec3[] vertexArray( float width, float height, int width_count, int height_count )
    {
        import desmath;
        vec3[] result;
        float width_step  = width / width_count;
        float height_step = height / height_count;
        for (int i = 0; i < width_count; i += width_step)
            for (int j = 0; j < height_count; j += height_step)
            {   
                result ~= vec3(i, j,normal(0.0, 0.5));
                result ~= vec3(i + width_step, j, 0);
                result ~= vec3(i, j + height_step, 0);
                
                result ~= vec3(i, j + height_step, 0);
                result ~= vec3(i + width_step, j + height_step, 0);
                result ~= vec3(i + width_step, j, 0);
            }
        return result;
    }

public:
    this() { super(); }


    void setData( )
    {
        auto data = vertexArray(10, 10, 10, 10);
        pos.setData( data );
        import std.random;
        
        foreach( ref elem; data )
            elem = vec3( uniform( 0, 1.0 ), uniform( 0, 1.0 ), uniform( 0, 1.0 ) );
        col.setData( data );
        cnt = cast(int)data.length;
        needDraw = !!cnt;
    }
}
