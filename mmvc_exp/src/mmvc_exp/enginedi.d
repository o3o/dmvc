module mmvc_exp.enginedi;
version(unittest) { import unit_threaded; } else { enum ShouldFail; }

import std.stdio;
// non si possono usare std.signal perche' non implementabili nelle interfacce
alias Handler = void delegate();
interface IEngine {
   @property int rpm();
   @property void rpm(int value);
   bool isOverRpmLimit();
   void connect(Handler);
}

// Domain model
class Engine : IEngine {
   private int _rpm;
   @property int rpm() { return _rpm; }
   @property void rpm(int value) {
      if (_rpm != value) {
         _rpm = value;
         writeln("emit");
         emit();
      }
   }

   bool isOverRpmLimit() {
      return _rpm > 800;
   }

   private Handler h;
   void connect(Handler h) {
      writeln("conn");
      this.h = h;
   }

   private void emit() {
      if (h) {
         h();
      } else {
         writeln("null");
      }
   }
}

// Application model
class DialEngine : IEngine {
   private IEngine e;
   this(IEngine e) {
      assert(e !is null);
      this.e = e;
      this.e.connect(&notify);
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

   bool isOverRpmLimit() {
      return e.isOverRpmLimit;
   }

   private Handler h;
   void connect(Handler h) {
      this.h = h;
   }

   private void emit() {
      if (h) {
         writeln("emit AM");
         h();
      }
   }
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
