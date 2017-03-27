import std.stdio;
version(unittest) {}
else {
   void main(string[] args) {
      version (base) {
         import mmvc.engine;
         auto domainM = new Engine();
         auto appM = new DialEngine(domainM);
         auto view = new Dial(appM);
      }
      version (withdi) {
         import mmvc.enginedi;
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
      version (withdi2) {
         import mmvc.enginedi2;
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
