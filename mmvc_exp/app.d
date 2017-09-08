import std.stdio;
version(unittest) {}
else {
   void main(string[] args) {
      version (e0) {
         import mmvc.engine0;
         auto m = new Engine();
         auto view = new Dial(m);
      }
      version (ebase) {
         import mmvc_exp.engine;
         auto domainM = new Engine();
         auto appM = new DialEngine(domainM);
         auto view = new Dial(appM);
      }
      version (edi) {
         import mmvc_exp.enginedi;
         import endovena;
         Container container = new Container;
         // Domain mmodel
         container.register!(IEngine, Engine, Singleton)();
         // application model
         container.register!(DialEngine, Singleton);

         container.register!(Controller, Singleton);
         // view
         container.register!(Dial, Singleton);

         auto view = container.get!Dial;
      }
      version (edi2) {
         import mmvc_exp.enginedi2;
         import endovena;
         Container container = new Container;
         // Domain mmodel
         container.register!(Engine, Singleton)();
         // application model
         container.register!(DialEngine, Singleton)();

         container.register!(Controller, Singleton)();
         // view
         container.register!(Dial, Singleton)();

         auto view = container.get!Dial;
      }
      writeln("e: event");
      writeln("q: exit");

      char cmd;
      do {
         readf(" %s", &cmd);
         if (cmd == 'e') view.accelerateEvent();
      } while (cmd != 'q');
   }
}
