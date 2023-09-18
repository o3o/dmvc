module traditionalmvc.observer;
version(unittest) { import unit_threaded; } else { enum ShouldFail; }

import std.stdio;

/**
 * Interfaccia implementata da tutti gli osservatori
 */
interface IObserver {
   // `update` is better
   void notify();
}

/**
 * Il modello e' il soggetto e deve mantenere una lista degli osservatori
 *
 * Deve quindi esporre due metodi che permettono agli osservatori di registrarsi (e deregistrarsi)
 *
 */
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
   /**
    * Quando il valore cambia, notifica tutti gli osservatori
    */
   @property void value(int value) {
      if (_value != value) {
         _value = value;
         notifyListeners();
      }
   }

   void inc() {
      this.value = this.value + 1;
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

/**
 * Il controller contiene solo un riferimento al modello
 * Puo' avere o no un riferimento alla vista
 */
class Controller {
   private Model m;
   this(Model m) {
      this.m = m;
   }

   void addOne() {
      m.inc();
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

class View2 : IObserver {
   // il modello serve alla vista per usare direttamente i dati senza doverli passare nell'evento
   private Model m;
   private Controller ctrl;
   this(Model m, Controller ctrl) {
      assert(ctrl !is null);
      this.ctrl = ctrl;

      assert(m !is null);
      this.m = m;
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
