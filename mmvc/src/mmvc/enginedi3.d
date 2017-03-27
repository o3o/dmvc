module mmvc.enginedi3;
version(unittest) { import unit_threaded; } else { enum ShouldFail; }

import std.stdio;
// non si possono usare std.signal perche' non implementabili nelle interfacce
class Signal {
   alias handler = void delegate();
   private handler[] listeners;
   // `attach` is better. See http://www.dofactory.com/net/observer-design-pattern
   void register(handler v) {
      if (v) {
         listeners ~= v;
      }
   }

   // `detach` is better
   void unregister(void delegate() v) {
      size_t i = -1;
      foreach (j, h; listeners) {
         if (h is v) {
            i = j;
            break;
         }
      }
      if (i > -1) {
         listeners = listeners[0..i] ~ listeners[i+1..$];
      }
   }

   void emit() {
      foreach (l; listeners) {
         l();
      }
   }
   void connect(Handler);
}

class Signal2 {
   import std.signals;
   void emit() {
      rpmChanged.emit();
   }
   mixin Signal rpmChanged;
}

interface IEngine {
   @property int rpm();
   @property void rpm(int value);
   bool isOverRpmLimit();
}

// Domain model
class Engine : IEngine {
   private Signal s;
   this(Signal s) {
      assert(s !is null);
      this.s = s;
   }

   private int _rpm;
   @property int rpm() { return _rpm; }
   @property void rpm(int value) {
      if (_rpm != value) {
         _rpm = value;
         writeln("emit");
         s.emit();
      }
   }

   bool isOverRpmLimit() {
      return _rpm > 800;
   }
}

// Application model
class DialEngine : IEngine {
   private IEngine e;
   this(IEngine e, Signal s) {
      assert(e !is null);
      this.e = e;

      s.connect(&notify);
      writeln("Dial ctro");
   }

   private void notify() {
      if (e.isOverRpmLimit) {
         _color = "red";
      } else {
         _color = "green";
      }
      emit();
   }

   @property int rpm() { return e.rpm; }
   @property void rpm(int value) { e.rpm = value; }

   private string _color;
   @property string color() { return _color; }

}

/**
  Passando al Controller una interfaccia invece che una classe concreta,
  lo si rende testabile
  */
class Controller {
   private IEngine m;
   this(IEngine m) {
      this.m = m;
   }

   void accelerate() {
      m.rpm = m.rpm + 100;
   }
}

// view
class Dial {
   private DialEngine m;
   private Controller ctrl;
   this(DialEngine m, Controller ctrl) {
      assert(ctrl !is null);
      this.ctrl = ctrl;

      assert(m !is null);
      this.m = m;
      this.m.connect(&update);
   }

   void accelerateEvent() {
      ctrl.accelerate();
   }

   void update() {
      writefln("[DIAL] notify: set value to %s color %s", m.rpm, m.color);
   }
}
