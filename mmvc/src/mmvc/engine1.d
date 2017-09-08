/**
 * Seconda soluzione.
 *
 */
module mmvc.engine1;
version(unittest) {
   import unit_threaded;
}

import std.stdio;
import std.signals;

enum Qt {
   green,
   red
}

// Domain model
class Engine {
   private int _rpm;
   @property int rpm() { return _rpm; }
   @property void rpm(int value) {
      if (_rpm != value) {
         _rpm = value;
         rpmChanged.emit();
      }
   }
   //
   mixin Signal rpmChanged;
}

class Controller {
   this(Engine m) {
   }
}

// view
class Dial {
   private Engine e;
   private Controller ctrl;
   this(Engine e) {
      this.e = e;

      ctrl = new Controller(this.e);
      this.e.rpmChanged.connect(&update);
   }

   void update() {
      writefln("[DIAL] notify: set value to %s", e.rpm);
      if (e.rpm > 8000) {
         writefln("   set color to %s", Qt.red);
      } else {
         writefln("   set color to %s", Qt.green);
      }
   }
}
