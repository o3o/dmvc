module traditionalmvc.withsignal;
version(unittest) { import unit_threaded; } else { enum ShouldFail; }

import std.stdio;
import std.signals;
class Model {
   private int _value;
   @property int value() { return _value; }
   @property void value(int value) {
      if (_value != value) {
         _value = value;
         modelChanged.emit();
      }
   }
   mixin Signal modelChanged;
}

class Controller {
   private Model m;
   this(Model m) {
      this.m = m;
   }

   void addOne() {
      m.value = m.value + 1;
   }
}

class View {
   private Model m;
   private Controller ctrl;
   this(Model m) {
      this.m = m;
      ctrl = new Controller(m);
      m.modelChanged.connect(&notify);
   }

   /**
     It should be private.
     Public just to simulate event into main
    */
   void mouseReleasEvent() {
      ctrl.addOne();
   }

   void notify() {
      writefln("[SIGNAL] notify: set value to %s", m.value);
   }
}
