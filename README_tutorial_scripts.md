# README_tutorial_scripts.md

# 📖 Подробное руководство по скриптам UV + Ruff + Pre-commit

## 🎯 Общее назначение

Набор скриптов для автоматизации создания Python-проектов с предустановленными инструментами разработки. Экономит 20-30 минут ручной настройки на каждый проект!

## 📁 Структура скриптов

```
scripts/
├── setup-project.ps1         # Создание базового проекта
├── setup-precommit.ps1       # Настройка pre-commit хуков  
├── setup-full.ps1            # Полная настройка (проект + pre-commit)
└── commands.txt              # Готовые команды для копирования
```

## 🔧 setup-project.ps1 - Создание проекта

### Назначение
Создает базовую структуру Python-проекта с предустановленными инструментами.

### Что делает скрипт:
1. ✅ Проверяет и устанавливает UV (если нужно)
2. ✅ Создает структуру проекта
3. ✅ Инициализирует проект с указанной версией Python
4. ✅ Создает виртуальное окружение
5. ✅ Настраивает Git репозиторий
6. ✅ Устанавливает Ruff и pre-commit
7. ✅ Добавляет настройки Ruff в pyproject.toml
8. ✅ Создает базовую структуру папок и файлов

### Пошаговый разбор кода

#### 1. Параметры скрипта
```powershell
param(
    [string]$ProjectName = "my_project",
    [string]$PythonVersion = "3.12", 
    [string]$ProjectPath = "D:\Start_project"
)
```
**Что это значит:**
- `$ProjectName` - имя проекта (по умолчанию: "my_project")
- `$PythonVersion` - версия Python (по умолчанию: 3.12)
- `$ProjectPath` - путь где создать проект (по умолчанию: D:\Start_project)

#### 2. Проверка существования проекта
```powershell
$FullProjectPath = Join-Path $ProjectPath $ProjectName
if (Test-Path $FullProjectPath) {
    Write-Host "❌ ОШИБКА: Проект '$ProjectName' уже существует" -ForegroundColor Red
    exit 1
}
```
**Что это значит:**
- `Join-Path` - объединяет путь и имя проекта
- `Test-Path` - проверяет существует ли папка
- Если проект существует - скрипт завершается с ошибкой

#### 3. Проверка и установка UV
```powershell
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "📦 Установка UV..." -ForegroundColor Yellow
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
}
```
**Что это значит:**
- `Get-Command uv` - пытается найти команду `uv`
- `-ErrorAction SilentlyContinue` - подавляет ошибки если команда не найдена
- `-not` - инвертирует результат (True если команда НЕ найдена)
- `irm` = `Invoke-RestMethod` - скачивает скрипт установки
- `iex` = `Invoke-Expression` - выполняет скрипт

#### 4. Создание папки проекта
```powershell
New-Item -ItemType Directory -Path $FullProjectPath -Force | Out-Null
Set-Location $FullProjectPath
```
**Что это значит:**
- `New-Item -ItemType Directory` - создает новую папку
- `-Force` - перезаписывает если существует
- `| Out-Null` - скрывает вывод команды
- `Set-Location` - переходит в папку проекта

#### 5. Инициализация проекта UV
```powershell
uv init --python $PythonVersion .
uv venv
```
**Что это значит:**
- `uv init --python 3.12 .` - инициализирует проект с Python 3.12 в текущей папке
- `uv venv` - создает виртуальное окружение в папке `.venv`

#### 6. Активация виртуального окружения
```powershell
if (Test-Path ".venv\Scripts\Activate.ps1") {
    .\.venv\Scripts\activate
    Write-Host "✓ Виртуальное окружение активировано" -ForegroundColor Green
}
```
**Что это значит:**
- `Test-Path` - проверяет существует ли файл активации
- `.\activate.ps1` - выполняет скрипт активации окружения
- **Важно:** Окружение активируется только на время работы скрипта

#### 7. Настройка Git
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore" -OutFile ".gitignore"
git init
git add .gitignore  
git commit -m "Add gitignore"
```
**Что это значит:**
- `Invoke-WebRequest` - скачивает стандартный .gitignore для Python
- `git init` - инициализирует Git репозиторий
- `git add` - добавляет файл в индекс
- `git commit` - создает первый коммит

#### 8. Установка инструментов разработки
```powershell
uv add ruff pre-commit --dev
```
**Что это значит:**
- `uv add` - устанавливает пакеты
- `--dev` - устанавливает как dev-зависимости

#### 9. Добавление настроек Ruff
```powershell
$pyprojectContent = Get-Content -Path "pyproject.toml" -Raw
$ruffConfig = @"...конфиг Ruff...“@
$pyprojectContent + $ruffConfig | Out-File -FilePath "pyproject.toml" -Encoding UTF8
```
**Что это значит:**
- `Get-Content -Raw` - читает весь файл как одну строку
- `$ruffConfig` - многострочная строка с настройками Ruff
- `+` - объединяет существующий контент с новыми настройками
- `Out-File` - записывает обратно в файл

#### 10. Создание структуры проекта
```powershell
New-Item -ItemType Directory -Name "src" -Force | Out-Null
New-Item -ItemType Directory -Name "tests" -Force | Out-Null
```
**Что это значит:**
- Создает папки `src/` и `tests/` для исходного кода и тестов

### Использование:
```powershell
.\scripts\setup-project.ps1 -ProjectName "my_app" -PythonVersion "3.12" -ProjectPath "D:\"
```

## ⚙️ setup-precommit.ps1 - Настройка Pre-commit

### Назначение
Добавляет автоматические проверки кода через pre-commit хуки.

### Что делает скрипт:
1. ✅ Проверяет что запущен из папки проекта
2. ✅ Активирует виртуальное окружение
3. ✅ Создает конфигурацию pre-commit
4. ✅ Устанавливает git hooks
5. ✅ Обновляет конфигурацию
6. ✅ Запускает тестовую проверку

### Ключевые особенности:
- **Исключает конфигурационные файлы** из проверок на пробелы
- **Автоматическое обновление** версий хуков
- **Тестовая проверка** сразу после настройки

### Конфигурация pre-commit:
```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.13.0
    hooks:
      - id: ruff          # Линтинг кода
      - id: ruff-format   # Форматирование кода

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace    # Проверка пробелов
      - id: end-of-file-fixer      # Исправление конца файлов
      - id: check-yaml             # Проверка YAML файлов
      - id: check-added-large-files # Проверка больших файлов
      - id: check-merge-conflict   # Проверка конфликтов слияния
      - id: detect-private-key     # Обнаружение приватных ключей
```

**Исключения:** Конфигурационные файлы исключены из проверок пробелов:
```yaml
exclude: ^(pyproject\.toml|\.pre-commit-config\.yaml|\.gitignore|ruff\.toml|\.env|\.flake8)$
```

### Использование:
```powershell
# Запускать из папки проекта:
.\scripts\setup-precommit.ps1
```

## 🚀 setup-full.ps1 - Полная настройка

### Назначение
Комплексная настройка проекта (вызывает оба скрипта).

### Что делает скрипт:
1. ✅ Вызывает `setup-project.ps1` - создает проект
2. ✅ Вызывает `setup-precommit.ps1` - настраивает pre-commit
3. ✅ Полностью готовая среда разработки

### Использование:
```powershell
.\scripts\setup-full.ps1 -ProjectName "my_app" -PythonVersion "3.12" -ProjectPath "D:\"
```

## 🎯 После запуска скриптов

### Проект готов к использованию!
- ✅ Виртуальное окружение **уже активировано**
- ✅ Все зависимости **уже установлены**
- ✅ Git репозиторий **уже настроен**
- ✅ Pre-commit хуки **уже установлены**

### Дальнейшие действия:

#### Вариант 1: Работа в IDE (рекомендуется)
1. **Откройте проект в PyCharm/VSCode**
2. **IDE автоматически определит:**
   - Виртуальное окружение `.venv`
   - Python интерпретатор
   - Все зависимости
   - Настройки code style

#### Вариант 2: Работа в терминале
1. **Перейдите в папку проекта**: `cd D:\my_app`
2. **Активируйте окружение** (если нужно): `.\venv\Scripts\activate`
3. **Добавьте зависимости**: `uv add pandas numpy matplotlib`
4. **Запустите проверки**: `pre-commit run --all-files`

### Проверка активации:
В командной строке должен отображаться признак активированного окружения:
```
(my_app) PS D:\my_app> 
```

## 💡 Примеры использования

### Создать проект с настройками по умолчанию:
```powershell
.\scripts\setup-project.ps1
```

### Создать проект с кастомными параметрами:
```powershell
.\scripts\setup-project.ps1 -ProjectName "my_api" -PythonVersion "3.11" -ProjectPath "D:\projects"
```

### Создать проект в текущей папке:
```powershell
.\scripts\setup-project.ps1 -ProjectName "web_app" -ProjectPath "."
```

### Полная настройка проекта:
```powershell
.\scripts\setup-full.ps1 -ProjectName "full_project" -PythonVersion "3.12" -ProjectPath "D:\"
```

## ⚠️ Решение проблем

### Ошибка выполнения скриптов:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

### Ошибка при установке UV:
Проверьте подключение к интернету и права администратора

### Проект уже существует:
Используйте другое имя проекта или удалите существующую папку

### Pre-commit не работает:
```powershell
pre-commit autoupdate
pre-commit install --force
```

## 📊 Преимущества использования

### Экономия времени:
| Операция | Вручную | Со скриптами |
|----------|---------|-------------|
| Создание проекта | 5-10 мин | 5 сек |
| Настройка окружения | 5-10 мин | 0 сек |
| Настройка линтеров | 5-10 мин | 0 сек |
| Настройка pre-commit | 5-10 мин | 0 сек |
| **Итого** | **20-40 мин** | **60 сек** |

### Стандартизация:
- Единые настройки code style для всех проектов
- Автоматические проверки перед каждым коммитом
- Предсказуемая структура проектов

## 🚀 Рекомендации по использованию

1. **Храните скрипты в постоянной папке** (например `D:\scripts\`)
2. **Используйте commands.txt** для быстрого копирования команд
3. **Начинайте с setup-full.ps1** для полной настройки
4. **Открывайте проекты в IDE** для автоматического определения настроек
5. **Добавляйте зависимости через UV**: `uv add <package>`

## 🔧 Для продвинутых пользователей

### Кастомизация настроек:
Редактируйте настройки в скриптах:
- Настройки Ruff в `setup-project.ps1`
- Конфигурацию pre-commit в `setup-precommit.ps1`

### Добавление своих хуков:
Дополните конфигурацию pre-commit в скрипте `setup-precommit.ps1`

### Интеграция с CI/CD:
Используйте созданные конфигурации для настройки pipelines

---

**Теперь вы можете создавать полностью настроенные Python-проекты за 60 секунд!** 🎉