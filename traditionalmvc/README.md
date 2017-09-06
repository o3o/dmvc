# Traditional MVC
See [Chap 1.3](https://stefanoborini.gitbooks.io/modelviewcontroller/content/01_from_smartui_to_traditional_mvc/03_traditional_mvc.html)

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

Sono implementate due modalità di creazione: nella prima la vista riceve nel costruttore il modello crea il controller e si registra nel modello stesso. Nella seconda queste operazioni sono fatte al di fuori della vista  e al
construttore della vista è passato solo il controller e il modello

| conosce ? | M   | C   | V   |
| ---       | --- | --- | --- |
| M         | xxx | NO  | NO  |
| C         | SI  | xxx | (1) |
| V         | SI  | SI  | xxx |

(1) Il controller può o meno conoscere la vista.

Nel modo 1, il controller è creato all'interno della vista:
```
 ctrl = new Controller(m);
 m.register(this);
```
sembra contrario alla DI, perchè in questo modo non si possono passare controller diversi (es. mock).
In realtà non ha senso passare controller diversi, sia perchè (pag.29 UMVC):

> Controllers are associated to Views in a strong one-to-one mutual dependency, and can be described as the "business logic" of the View.

sia perche' anche passando un mock, non si riesce ad attivare l'evento `mouseReleasEvent` che permetterebbe di verificare che il mock riceva `addOne`

In ogni caso si puo' passare il controller tramite `setController`: non e' in generale  possibile passarlo nel costruttore, perchè per construire il controller serve la vista e per costruire la vista serve il controller.
Quindi:
1. la vista crea il suo controller
2. il controller passa se stesso alla vista tramite setController

## Signal/slot
Si usa l'implementazione nativa di signal/slot: basta aggiungere un `mixin Signal` al soggetto e questo ha un evento `emit` e connect

Anche qui la costruzione è eseguita nella vista: la vista riceve il modelllo nel costruttore crea il controller e registra le funzioni slot nel segnale del modello (`connect`). Si può anche fare esternamente come in view2



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

## Compilazione
- observer (`dub -co`)
- delegate (`dub -cdel`)
- signal (`dub -csig`)


