import std.stdio;
version(unittest) {}
else {
   void main(string[] args) {
      version (del) {
         writeln("WITH DELEGATE");
         import traditionalmvc.withdelegate;
         Model m  = new Model();
         View v = new View(m);
      }
      version (observer) {
         writeln("OBSERVER");
         import traditionalmvc.observer;
         Model m  = new Model();
         View v = new View(m);
      }
      writeln("e: event");
      writeln("q: exit");
      char cmd;
      do {
         readf(" %s", &cmd);
         //writefln("> '%s'", cmd);
         if (cmd == 'e') v.mouseReleasEvent();
      } while (cmd != 'q');
   }
}
