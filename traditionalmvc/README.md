# Traditional MVC

See [Chap 1.3](https://stefanoborini.gitbooks.io/modelviewcontroller/content/01_from_smartui_to_traditional_mvc/03_traditional_mvc.html)

> To summarize the scope of each role in Traditional MVC:

- Model: holds the application's state and core functionality (Domain logic).
- View: visually renders the Model to the User (Presentation logic).
- Controller: mediates User actions on the GUI to drive modifications on the Model (Application logic).


> Depending on the specifics of the application, a Controller may or may not need a reference to the View, but it certainly needs the Model to apply changes on.

## Test
### Model
- Quando si imposta `value` i listeners devono ricevere la notifica solo se il valore cambia
-
### Controller
- `addOne` deve incrementare `value` del modell

### View
Questa e' la parte delicata.
In PF si verificava che quando la vista generava un evento il presenter lo reinstradasse al modello

```
| M              | P | V                     | User           |
|                |   |                       | <--- click --- |
|                |   | <~~~ addRqs event ~~~ |                |
| <---- incr --- |   |                       |                |

```
Al presenter si passavano i mock del modello e vista:
Il test e'
> Quando si genera l'evento addRqs il presente deve incrementare il modello

Per testare che il presenter chiamasse addOne, l'evento `addRequested` era generato dal mock.
**NON** si testa che l'evento si generi sul click dell'operatore, perché la vista non è testabile.

Qui la vista chiama direttamente il metodo `addOne` del controller in quanto lo conosce.

```
| M              | C | V               | User           |
|                |   |                 | <--- click --- |
|                |   | <--- addOne --- |                |
| <---- incr --- |   |                 |                |
```

Sembrerebbe non testabile, in realta' e si riformula il test come:
> Quando si chiama addOne il controller deve incrementare il modello

e' testabile nello stesso modo di PF: la vista era e resta ancora esclusa.


## Note
Il controller è creato all'interno della vista:
```
 ctrl = new Controller(m);
 m.register(this);
```
sembra contrario alla DI, perche in questo modo non si possono passare contrller diversi (es. mock).
In realta' non ha senso passare controller diversi, sia perche:

> Controllers are associated to Views in a strong one-to-one mutual dependency, and can be described as the "business logic" of the View.

sia perche' anche passando un mock, non si riesce ad attivare l'evento `mouseReleasEvent` che permetterebbe di verificare che il mock riceva `addOne`

In ogni caso si puo' passare il controller tramite `setController`: non e' comunque possibile passarlo nel costruttore, perche' per construire il controller

