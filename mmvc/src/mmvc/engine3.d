module mmvc.engine3;

import std.stdio;
import std.signals;
enum Qt {
   green,
   red
}

// Domain model
class Engine  {
   private int _rpm;
   @property int rpm() { return _rpm; }
   @property void rpm(int value) {
      if (_rpm != value) {
         _rpm = value;
         rpmChanged.emit();
      }
   }

   bool isOverRpmLimit() {
      return _rpm > 8000;
   }
   mixin Signal rpmChanged;
}

// Application model
class DialEngine {
   private Engine e;
   this(Engine e) {
      assert(e !is null);
      this.e = e;
      this.e.rpmChanged.connect(&notify);
   }

   private void notify() {
      if (e.isOverRpmLimit) {
         _color = Qt.red;
      } else {
         _color = Qt.green;
      }
      rpmChanged.emit();
   }

   @property int rpm() { return e.rpm; }
   @property void rpm(int value) {
      e.rpm = value;
   }

   private Qt _color;
   @property Qt color() { return _color; }

   mixin Signal rpmChanged;
}

// il ctl deve ricevere Engine o DialEngine?
class Controller {
   private DialEngine m;
   this(DialEngine m) {
      this.m = m;
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

   void update() {
      writefln("[DIAL 3] notify: set value to %s color %s", m.rpm, m.color);
   }
}
