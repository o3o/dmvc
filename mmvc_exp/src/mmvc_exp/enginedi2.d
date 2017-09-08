module mmvc_exp.enginedi2;
version(unittest) { import unit_threaded; } else { enum ShouldFail; }

/**
  In questa versione si utilizzano classi concrete,
  in questo modo e' possibile usare connect di std.signal

  I porblemi sorgono se model ha bisogno di altri servizi complessi:
  in questo caso e' difficile testare Controller, in quanto non gli si puo' passare un mock
  */

import std.stdio;
import std.signals;


// Domain model
class Engine {
   private int _rpm;
   @property int rpm() { return _rpm; }
   @property void rpm(int value) {
      if (_rpm != value) {
         _rpm = value;
         rpmChanged.emit();
      writefln("[Engine] emit: set value to %s", _rpm);
      }
   }

   bool isOverRpmLimit() {
      return _rpm > 800;
   }
   mixin Signal rpmChanged;
}

// Application model
class DialEngine {
   private Engine e;
   this(Engine e) {
      assert(e !is null);
      this.e = e;
      this.e.rpmChanged.connect(&this.notify);
   }

   private void notify() {
      if (e.isOverRpmLimit) {
         _color = "red";
      } else {
         _color = "green";
      }
      rpmChanged.emit();
   }

   @property int rpm() { return e.rpm; }
   @property void rpm(int value) { e.rpm = value; }

   private string _color;
   @property string color() { return _color; }

   mixin Signal rpmChanged;
}

class Controller {
   private Engine m;
   this(Engine m) {
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
      writeln("ctor");

      this.m.rpmChanged.connect(&update);
   }

   void accelerateEvent() {
      ctrl.accelerate();
   }

   void update() {
      writefln("[DI2] notify: set value to %s color %s", m.rpm, m.color);
   }
}
