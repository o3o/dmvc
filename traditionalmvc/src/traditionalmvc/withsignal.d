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
   void inc() {
      this.value = this.value + 1;
   }

   /**
    * A questo segnale possono connettersi funzioni del tipo
    * void f()
    */
   mixin Signal modelChanged;
}

class Controller {
   private Model m;
   this(Model m) {
      this.m = m;
   }

   void addOne() {
      m.inc();
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

   void mouseReleasEvent() {
      ctrl.addOne();
   }

   void notify() {
      writefln("[SIGNAL] notify: set value to %s", m.value);
   }
}

class View2 {
   private Model m;
   private Controller ctrl;
   this(Model m, Controller ctrl) {
      assert(m !is null);
      this.m = m;

      assert(ctrl !is null);
      this.ctrl = ctrl;

      m.modelChanged.connect(&notify);
   }

   void mouseReleasEvent() {
      ctrl.addOne();
   }

   void notify() {
      writefln("[SIGNAL] notify: set value to %s", m.value);
   }
}
