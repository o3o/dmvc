# Traditional MVC
See [Chap 1.3](https://stefanoborini.gitbooks.io/modelviewcontroller/content/01_from_smartui_to_traditional_mvc/03_traditional_mvc.html)

> To summarize the scope of each role in Traditional MVC:

- Model: holds the application's state and core functionality (Domain logic).
- View: visually renders the Model to the User (Presentation logic).
- Controller: mediates User actions on the GUI to drive modifications on the Model (Application logic).

> Depending on the specifics of the application, a Controller may or may not need a reference to the View, but it certainly needs the Model to apply changes on.

## Struttura
Lo scopo è simulare il comportamento di una vista in cui premendo il pulsante `add` un valore e' incrementato e visualizzato sulla vista stessa

L'esempio rappresenta

## Test
### Model
- Quando si imposta `value` i listeners devono ricevere la notifica solo se il valore cambia

### Controller
- `addOne` deve incrementare `value` del model

### View
La vista non è testabile, nel senso che non si può testare che la vista esegua qualche azione a fronte di un click.


## Contronto con PF
In PF si verifica che quando la vista genera un evento il presenter lo reinstradi al modello

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
    |              |             |<--- click --- -|-
    |              |<-- addOne --|               / \
    |<---- incr ---|             |
```

Sembrerebbe non testabile, in realta' e si riformula il test come:
> Quando si chiama `addOne` il controller deve incrementare il modello

è testabile nello stesso modo di PF: la vista era e resta ancora esclusa.


## Note
Il controller è creato all'interno della vista:
```
 ctrl = new Controller(m);
 m.register(this);
```
sembra contrario alla DI, perche in questo modo non si possono passare contrller diversi (es. mock).
In realta' non ha senso passare controller diversi, sia perche':

> Controllers are associated to Views in a strong one-to-one mutual dependency, and can be described as the "business logic" of the View.

sia perche' anche passando un mock, non si riesce ad attivare l'evento `mouseReleasEvent` che permetterebbe di verificare che il mock riceva `addOne`

In ogni caso si puo' passare il controller tramite `setController`: non e' in generale  possibile passarlo nel costruttore, perche' per construire il controller serve la vista 
e per costruire la vista serve il controller.
Quindi
1. la vista crea il suo controller
2. il controller passa se stesso alla vista tramite setController

Come detto sopra non e' necessario che il controller conosca la vista, quindi si puo' semplicemente costruire il controller e passarlo alla vista nel costrutore