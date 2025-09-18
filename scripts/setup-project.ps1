param(
    [string]$ProjectName = "my_project",
    [string]$PythonVersion = "3.12",
    [string]$ProjectPath = "D:\Start_project"
)

Write-Host "🚀 Создание проекта $ProjectName" -ForegroundColor Green

$FullProjectPath = Join-Path $ProjectPath $ProjectName

if (Test-Path $FullProjectPath) {
    Write-Host "❌ ОШИБКА: Проект '$ProjectName' уже существует" -ForegroundColor Red
    Write-Host "📍 $FullProjectPath" -ForegroundColor Red
    Write-Host "💡 Используйте другое имя: .\setup-project.ps1 -ProjectName 'новое_имя'" -ForegroundColor Yellow
    exit 1
}

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "📦 Установка UV..." -ForegroundColor Yellow
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
}

New-Item -ItemType Directory -Path $FullProjectPath -Force | Out-Null
Set-Location $FullProjectPath
Write-Host "✓ Создана директория проекта: $FullProjectPath" -ForegroundColor Green

uv init --python $PythonVersion .
uv venv

if (Test-Path ".venv\Scripts\Activate.ps1") {
    .\.venv\Scripts\activate
    Write-Host "✓ Виртуальное окружение активировано" -ForegroundColor Green
}

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore" -OutFile ".gitignore"
git init
git add .gitignore
git commit -m "Add gitignore"

uv add ruff pre-commit --dev

# ДОБАВЛЯЕМ настройки Ruff к существующему pyproject.toml, а не перезаписываем
Write-Host "⚙️ Добавление настроек Ruff в pyproject.toml..." -ForegroundColor Yellow

# Читаем существующий файл
$pyprojectContent = Get-Content -Path "pyproject.toml" -Raw

# Добавляем настройки Ruff в конец файла
$ruffConfig = @"

[tool.ruff]
line-length = 88
select = ["E", "F", "W", "I", "B", "C4", "UP", "PL", "RUF"]
ignore = ["E501"]

[tool.ruff.lint]
per-file-ignores = { "__init__.py" = ["F401"] }

[tool.ruff.format]
quote-style = "double"
indent-width = 4

[tool.ruff.isort]
known-first-party = ["$ProjectName"]
"@

# Сохраняем обновленный файл
$pyprojectContent + $ruffConfig | Out-File -FilePath "pyproject.toml" -Encoding UTF8

# Создание базовой структуры проекта
New-Item -ItemType Directory -Name "src" -Force | Out-Null
New-Item -ItemType Directory -Name "tests" -Force | Out-Null

@"
\"\"\"Основной модуль проекта $ProjectName.\"\"\"

def hello_world() -> str:
    \"\"\"Возвращает приветственное сообщение.\"\"\"
    return \"Hello, World!\"


if __name__ == \"__main__\":
    print(hello_world())
"@ | Out-File -FilePath "src\__init__.py" -Encoding UTF8

@"
\"\"\"Основной модуль проекта $ProjectName.\"\"\"

def hello_world() -> str:
    \"\"\"Возвращает приветственное сообщение.\"\"\"
    return \"Hello, World!\"


if __name__ == \"__main__\":
    print(hello_world())
"@ | Out-File -FilePath "src\main.py" -Encoding UTF8

Write-Host "✅ Базовый проект $ProjectName успешно создан!" -ForegroundColor Green
Write-Host "💡 Для настройки pre-commit выполните: .\setup-precommit.ps1" -ForegroundColor Yellow