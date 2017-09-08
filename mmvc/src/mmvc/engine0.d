/**
 * Prima soluzione.
 *
 * Il colore del dial e' deciso dal modello, In questo modo Engine e' legato alle Qt e quindi dipende dalla GUI
 *
 * Il modello devia dalla sua natura legata al business e deve trattare elementi associati alla gui
 */
module mmvc.engine0;
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
   //We could violate Traditional MVC and add visual information to the Model, specifically the color
   Qt dialColor() {
      if (_rpm > 8000) {
         return Qt.red;
      } else {
         return Qt.green;
      }
   }
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
      writefln("[DIAL] notify: set value to %s color %s", e.rpm, e.dialColor);
   }
}
