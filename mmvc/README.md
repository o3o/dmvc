# MMCV
Application Model (MMVC)
See [Chap. 2.1.3](https://stefanoborini.gitbooks.io/modelviewcontroller/content/02_mvc_variations/variations_on_the_model/03_application_model.html)

>In Traditional MVC we pointed out that a Model object should not contain GUI state. In practice, some applications need to preserve and manage state that is only relevant for visualization. Traditional MVC has no place for it, but we can satisfy this need with a specialized Compositing Model: the Application Model, also known as Presentation Model. Its submodel, called Domain Model, will be kept unaware of such state.

```
+------+       +------+       +-----+   +-----+
|  DM  |       |  AM  |       |  C  |   |  V  |
+------+       +------+       +-----+   +-----+
   |              |              |         |<---- click on acc
   |              |              |<-- acc -|
   |              |<--- rpm+100--|         |
  I|<--- rpm+100--|              |         |
  I|              |                        |
  I|--- notify -->|                        |
   |              |------ notify --------->|
```
