import std.stdio;

import kiapp;

void main()
{
    writeln( "Init" );

    KiApp app = new KiApp();
    app.run();
    app.destroy();

    writeln( "Shutdown" );
}
