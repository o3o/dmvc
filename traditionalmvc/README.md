# Traditional MVC
Vedi [Chap 1.3] (https://stefanoborini.com/book-modelviewcontroller/01-basics-of-mvc/03-traditional-mvc.html):

> To summarize the scope of each role in Traditional MVC:

- Model: holds the application's state and core functionality (Domain logic).
- View: visually renders the Model to the User (Presentation logic).
- Controller: mediates User actions on the GUI to drive modifications on the Model (Application logic).

> Depending on the specifics of the application, a Controller may or may not need a reference to the View, but it certainly needs the Model to apply changes on.

## Struttura
Lo scopo è simulare il comportamento di una vista in cui premendo il pulsante `add` un valore e' incrementato e visualizzato sulla vista stessa.
Si confrontano diverse implementazioni:
- con il pattern Observer
- con i delegate
- con signal/slot


## Observer
Il modello è il soggetto che notifica a tutti gli osservatori il verificarsi di un evento (in questo caso la modifica di `value`).
Gli osservatori devono registrarsi nel modello (con il metodo `register`) e quindi devono implementare una interfaccia comune `IObserver`.


Sono implementate due modalità di creazione: nella prima la vista riceve nel costruttore il modello,  crea il controller e si registra nel modello stesso.

### Creazione controller interna
```d
class View : IObserver {
   private Model m;
   private Controller ctrl;
   this(Model m) {
      this.m = m;
      ctrl = new Controller(m);
      m.register(this);
   }

```
il controller è creato all'interno della vista
```
 ctrl = new Controller(m);
 m.register(this);
```
sembra contrario alla DI, perché in questo modo non si possono passare controller diversi (es. mock).
In realtà non ha senso passare controller diversi, sia perchè (pag.29 UMVC):

> Controllers are associated to Views in a strong one-to-one mutual dependency, and can be described as the "business logic" of the View.

sia perché anche passando un controller mock, non si riesce ad attivare l'evento `mouseReleasEvent` che permetterebbe di verificare che il mock riceva `addOne`

In ogni caso si può passare il controller tramite `setController`: non è in generale possibile passarlo nel costruttore, perchè per construire il controller serve la vista e per costruire la vista serve il controller.
Quindi:
1. la vista crea il suo controller
2. il controller passa se stesso alla vista tramite setController
Le relazioni di conoscenza sono

| conosce ? | M   | C   | V   |
| ---       | --- | --- | --- |
| M         |     | NO  | NO  |
| C         | SI  |     | (1) |
| V         | SI  | SI  |     |

(1) Il controller può o meno conoscere la vista.


### Creazione esterna
Nella seconda queste operazioni sono fatte al di fuori della vista  e al construttore
della vista è passato solo il controller e il modello, sempre che il controller non necessiti della vista.
```d
class View2 : IObserver {
   // il modello serve alla vista per usare direttamente i dati senza doverli passare nell'evento
   private Model m;
   private Controller ctrl;
   this(Model m, Controller ctrl) {
      this.ctrl = ctrl;
      this.m = m;
   }
   ...
void main() {
    Model m = new Model();
    Controller  = new Controller(m);
```

| conosce ? | M   | C   | V   |
| ---       | --- | --- | --- |
| M         |     | NO  | NO  |
| C         | SI  |     | NO |
| V         | SI  | SI  |     |


## Signal/slot
Si usa l'implementazione nativa di signal/slot: basta aggiungere un `mixin Signal` al soggetto e questo ha un evento `emit` e `connect`

Anche qui la costruzione è eseguita nella vista: la vista riceve il modello nel costruttore, crea il controller e registra le funzioni slot nel segnale del modello (`connect`).
```d
class View {
   private Model m;
   private Controller ctrl;
   this(Model m) {
      this.m = m;
      // crea il controller
      ctrl = new Controller(m);
      // registra la funzione da chiamare
      m.modelChanged.connect(&notify);
   }
   ...

   void notify() {
       ....
```


Si può anche fare esternamente come in view2

## Test
### Model
- Quando si imposta `value` i listeners devono ricevere la notifica solo se il valore cambia

### Controller
- `addOne` deve incrementare `value` del model

### View
La vista non è testabile, nel senso che non si può testare che la vista esegua qualche azione a fronte di un click.

## Contronto con PF
In PF si verifica che quando la vista genera un evento il presenter lo re-instradi al modello

```
+-------+      +-------+           +-------+
|   M   |      |   P   |           |   V   |
+-------+      +-------+           +-------+            o
    |              |                   |<--- click --- -|-
    |              |<--*addRqs event --|               / \
    |<---- incr ---|                   |

```

Al presenter si passa i mock del modello e della vista.
Il test è:
> Quando si genera l'evento `addRqs` il presenter deve incrementare il modello

Per testare che il presenter chiami `addOne`, il mock della vista genera l'evento `addRqs` e si verifica che il mock del modello riceva `incr`.
**NON** si testa che l'evento si generi sul click dell'operatore, perché la vista non è testabile.

In MVC la vista chiama direttamente il metodo `addOne` del controller in quanto lo conosce.

```
+-------+      +-------+     +-------+
|   M   |      |   C   |     |   V   |
+-------+      +-------+     +-------+            o
    |              |             |<--- click --- -O-
    |              |<-- addOne --|               / \
    |<---- incr ---|             |
```

Sembrerebbe non testabile, in realta' e si riformula il test come:
> Quando si chiama `addOne` il controller deve incrementare il modello

è testabile nello stesso modo di PF: la vista era e resta ancora esclusa.

## Compilazione
- observer (`dub -co`)
- delegate (`dub -cdel`)
- signal (`dub -csig`)

Come detto sopra non è necessario che il controller conosca la vista, quindi si puo' semplicemente costruire il controller e passarlo alla vista nel costruttore
