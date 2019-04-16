module compositionmodel.model;
version(unittest) { import unit_threaded; } else { enum ShouldFail; }

interface IAddressBook {
   int numEntries();

}

class AddressBookCSV {
   private string fn;
   this(string fn) {
      assert(fn.length > 0);
      this.fn = fn;
   }

}
