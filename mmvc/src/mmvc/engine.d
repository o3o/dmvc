module mmvc.engine;

version(unittest) { import unit_threaded; } else { enum ShouldFail; }

import std.stdio;
import std.signals;
interface IEngine {
   @property int rpm();
   @property void rpm(int value);
}

// Domain model
class Engine : IEngine {
   private int _rpm;
   @property int rpm() { return _rpm; }
   @property void rpm(int value) {
      if (_rpm != value) {
         _rpm = value;
         rpmChanged.emit();
      }
   }

   bool isOverRpmLimit() {
      return _rpm > 800;
   }
   mixin Signal rpmChanged;
}

// Application model
class DialEngine : IEngine {
   private Engine e;
   this(Engine e) {
      assert(e !is null);
      this.e = e;
      this.e.rpmChanged.connect(&notify);
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
   @property void rpm(int value) {
      e.rpm = value;
   }

   private string _color;
   @property string color() { return _color; }

   mixin Signal rpmChanged;
}

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
   this(DialEngine m) {
      this.m = m;

      ctrl = new Controller(this.m);
      this.m.rpmChanged.connect(&update);
   }

   void accelerateEvent() {
      ctrl.accelerate();
   }

   void update() {
      writefln("[DIAL] notify: set value to %s color %s", m.rpm, m.color);
   }
}
