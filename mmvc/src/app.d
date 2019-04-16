version(unittest) {}
else {
   void main(string[] args) {
      version (e0) {
         import mmvc.engine0;
         auto m = new Engine();
         auto view = new Dial(m);
      }
      version (e1) {
         import mmvc.engine1;
         auto m = new Engine();
         auto view = new Dial(m);
      }
      version (e2) {
         import mmvc.engine2;
         auto m = new Engine();
         auto view = new Dial(m);
      }
      version (e3) {
         import mmvc.engine3;
         auto e = new Engine();
         auto m = new DialEngine(e);
         auto view = new Dial(m);
      }
      m.rpm = 100;
      m.rpm = 8100;
   }
}
