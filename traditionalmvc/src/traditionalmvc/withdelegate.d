module traditionalmvc.withdelegate;
version(unittest) { import unit_threaded; } else { enum ShouldFail; }

import std.stdio;

class Model {
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

   private int _value;
   @property int value() { return _value; }
   @property void value(int value) {
      if (_value != value) {
         _value = value;
         notifyListeners();
      }
   }

   void notifyListeners() {
      foreach (l; listeners) {
         l();
      }
   }
}
/+
@("notifyListeners should call notify") unittest {
   int calls = 0;
   Model m = new Model();
   m.register({++calls;});

   m.value = 42;
   calls.shouldEqual(42);
}
+/

class Controller {
   private Model m;
   this(Model m) {
      this.m = m;
   }

   void addOne() {
      m.value = m.value + 1;
   }
}
//@("addOne should call value")
/+unittest {
   Model m = new Model();
   Controller c = new Controller(m);
   m.value.shouldEqual(0);
   c.addOne();
   m.value.shouldEqual(0);
}
+/


class View  {
   private Model m;
   private Controller ctrl;
   this(Model m) {
      this.m = m;
      ctrl = new Controller(m);
      m.register(&this.notify);
   }

   /**
     It should be private.
     Public just to simulate event into main
    */
   void mouseReleasEvent() {
      ctrl.addOne();
   }

   void notify() {
      writefln("notify: set value to %s", m.value);
   }
}
