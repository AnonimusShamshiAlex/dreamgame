Вот перевод файла на русский:

---

# Dream Live (прототип Weirdcore / Dreamcore хаба)

3D-мир в стиле dreamcore/liminal-space от первого лица (FPS). Это — первая часть большой игры: центральный хаб, от которого вдалеке видны 4 локации (пляж, цирк, красный город, корпоративная башня), а в начале — объясняющий шоумен.

## Управление

- **На телефоне**: левая половина экрана = виртуальный джойстик (ходьба), правая половина = свайп пальцем = поворот камеры, кнопка в правом нижнем углу = прыжок.
- **На компьютере (для теста внутри Godot Editor)**: W/A/S/D — ходьба, мышь — обзор (нажать, затем мышь «захватывается»), Space — прыжок.

## Быстрая проверка (самый простой способ)

1. Скачай **Godot 4.3** с https://godotengine.org/download (бесплатно, установка не нужна — просто запускаемый файл).
2. Открой Godot → «Import» → выбери файл `project.godot` в этой папке.
3. Нажми **Play** (треугольник) вверху — мир откроется на твоём компьютере, можно ходить мышью/клавиатурой.

## Получение Android APK

Самый удобный способ — через `codemagic.yaml` в этой папке на Codemagic.io (как в проекте Elektron Hamyon): загрузи на GitHub, запусти в Codemagic workflow «Dream Live - Android», в конце в разделе Artifacts появится `build/*.apk`.

## Что есть в проекте

- `scripts/Main.gd` — весь мир строится здесь кодом: небо, туман, освещение, 4 далёкие локации, шоумен, экранные элементы управления, вступительный диалог.
- `scripts/Player.gd` — контроллер движения от первого лица.
- `scenes/Main.tscn` — стартовая сцена (почти пустая, только загружает скрипт).

Версии DreamLive

DreamLive 1v https://drive.google.com/file/d/1Yj8kMjLYXjnjjVIqqu9k8Aoi0CkcQZkb/view?usp=sharing

DreamLive 2v https://drive.google.com/file/d/1UDxxH4BeNRBJIQKdKNEzZLlQ8jXvps6M/view?usp=sharing

DreamLive 3v https://drive.google.com/file/d/161s9t7HQyNEE_WL7AMADAZJRvRt3VYOP/view?usp=sharing
