module traditionalmvc.multiobserver;

version(unittest) { import unit_threaded; } else { enum ShouldFail; }

import std.stdio;

interface IObserver {
   // `update` is better
   void notify();
}

class Model {
   private IObserver[] listeners;
   // `attach` is better. See http://www.dofactory.com/net/observer-design-pattern
   void register(IObserver v) {
      if (v) {
         listeners ~= v;
      }
   }

   // `detach` is better
   void unregister(IObserver v) {
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

   private void notifyListeners() {
      foreach (l; listeners) {
         l.notify();
      }
   }
}

unittest {
   //notifyListeners should call notify
   class Observer: IObserver {
      int calls;
      void notify() {
         ++calls;
      }
   }
   Model m = new Model();
   auto o = new Observer();
   m.register(o);
   assert(o.calls == 0);

   m.value = 42;
   assert(o.calls == 1);
   m.value = 42;
   assert(o.calls == 1);
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

@("addOne should call value")
unittest {
   Model m = new Model();
   Controller c = new Controller(m);
   c.addOne();
   m.value.shouldEqual(1);
}

class View : IObserver {
   private Model m;
   private Controller ctrl;
   this(Model m) {
      this.m = m;
      ctrl = new Controller(m);
      m.register(this);
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
