import std.stdio;
version(unittest) {}
else {
   void main(string[] args) {
      version (del) {
         writeln("WITH DELEGATE");
         import traditionalmvc.withdelegate;
         Model m = new Model();
         View v = new View(m);
      }
      version (observer) {
         writeln("OBSERVER");
         import traditionalmvc.observer;
         Model m = new Model();
         // la vista crea il suo controller internamente e si registra nel modello.
         View v = new View(m);
      }
      version (observer2) {
         writeln("OBSERVER2");
         import traditionalmvc.observer;
         Model m = new Model();
         // il controller e' creato esternamente alla vista, e la vista e' registrata esternamente
         auto ctrl = new Controller(m);
         View2 v = new View2(m, ctrl);
         m.register(v);
      }
      version (sig) {
         writeln("SIGNAL");
         import traditionalmvc.withsignal;
         Model m  = new Model();
         View v = new View(m);
      }
      version (sig2) {
         writeln("SIGNAL2");
         import traditionalmvc.withsignal;
         Model m = new Model();
         Controller ctrl = new Controller(m);
         View2 v = new View2(m, ctrl);
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
