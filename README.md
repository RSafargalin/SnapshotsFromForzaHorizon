[![N|Solid](https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/Forza_logo_2020.svg/1200px-Forza_logo_2020.svg.png)](https://forzamotorsport.net/en-US)

## Shapshots from Forza Horizon

Для получения изображений автомобилей использовался публичный(публичное API) сервис - [Forza-API.Tk](https://docs.forza-api.tk)

Данный учебный проект является приложением для просмотра изображений автомобилей из игровой вселенной **Forza** ©.

## Особенности

- Приложение при запуске загружает большинство уникальных изображений и сохраняет их в кэше(в реализации от 30.11.2021 в оперативной памяти с ограничением в 300 Мб)
- Для уменьшения нагрузки на сеть, а так же для уменьшения используемой оперативной памяти устройства приложение хранит только уникальные изображения. При дублировании изображений, дубликаты не загружаются, а используются ранее загруженные.
- В приложении реализована *бесконечная лента* с изображениями автомобилей. 

## Стэк

- Архитектура – MVC + Core слой (бизнес логика, сеть. В дальнейшем – БД)
- Менеджер зависимостей – SPM
- Зависимости – Alamofire + AlamofireImage
- UI в коде (констрейнты)

## Изображения
<details>
<summary>Изображения</summary>

![Launch Screen](https://sun9-26.userapi.com/impg/D_Eejw-D2ABidxMe4keILrM4OnmPKavGx3WXLQ/ftEF3ODobE4.jpg?size=1004x1878&quality=96&sign=07663690820654700fdea7be9ab8d1a0&type=album)

![Cars Screen](https://sun9-57.userapi.com/impg/TFhV14ClZTo4fTMMvhvVQJJ60qTR7iSGEiTLpw/__k2KBtAmjw.jpg?size=1004x1878&quality=96&sign=2e4432a9a2473fd18c3c826041c3d6ec&type=album)

</details>

## P.S.

Все изображения, логотипы, названия и иные материалы используемые в данном учебном проекте используются с сохранением прав правообладателей. Автор не претендует на авторство выше перечисленных материалов.