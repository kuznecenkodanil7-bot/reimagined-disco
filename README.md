# Nauzer Visuals — Fabric 1.21.11

Оригинальный клиентский визуальный мод в стиле визуальных клиентов. Это не прямая копия чужого Pulse Visuals: здесь нет украденных ассетов, названий модулей из закрытого клиента или обходов античита. Код можно спокойно менять под свой проект.

## Что уже реализовано

- RSHIFT — красивое меню модулей.
- H — быстро вкл/выкл основной HUD.
- Clean HUD: панель версии, координаты, направление взгляда.
- Active Modules: список включённых модулей справа.
- Armor HUD: броня и прочность.
- Pulse Crosshair: анимированный прицел.
- RGB Border: анимированная рамка экрана.
- Fullbright: клиентская яркость.
- Ambient Tint и Cinematic Overlay.
- Self Glow для своего персонажа.
- Trail Particles: частицы вокруг игрока.
- Hit Sparks: частицы при ударе по сущности.
- Mention Notify: уведомление при упоминании ника в чате.
- Keyword Notify: уведомления по словам из конфига.
- Chat Sound: звук при срабатывании уведомления.
- JSON-конфиг: `config/nauzer-visuals.json`.
- GitHub Actions сборка с загрузкой готового jar.

## Сборка локально

```bash
chmod +x ./gradlew
./gradlew build
```

Готовый jar появится в:

```text
build/libs/nauzer-visuals-1.0.0.jar
```

## Сборка через GitHub

1. Создай новый репозиторий.
2. Загрузи туда все файлы проекта.
3. Открой вкладку **Actions**.
4. Запусти workflow **Build Fabric Mod**.
5. Скачай артефакт `nauzer-visuals-jar`.

## Зависимости

- Minecraft Java Edition `1.21.11`
- Fabric Loader `0.19.2+`
- Fabric API `0.141.4+1.21.11`
- Java `21`

## Где менять стиль

- Цвета: `config/nauzer-visuals.json`, поля `accentStart` и `accentEnd`.
- Модули: `src/client/java/ru/nauzer/visuals/feature/ModuleRegistry.java`.
- HUD: `src/client/java/ru/nauzer/visuals/render/HudOverlay.java`.
- Меню: `src/client/java/ru/nauzer/visuals/screen/VisualScreen.java`.

## Важно

Мод сделан клиентским и косметическим. Я специально не добавлял ESP через стены, XRay, обходы античита, автодействия и другие функции, которые могут ломать правила серверов. Если нужен вариант чисто для своего сервера RaidMine/админ-инструментов, лучше добавлять серверную проверку доступа отдельно.
