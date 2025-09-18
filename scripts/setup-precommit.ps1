Write-Host "⚙️ Настройка pre-commit..." -ForegroundColor Yellow

# Проверка, что мы в проекте с UV
if (-not (Test-Path "pyproject.toml")) {
    Write-Host "❌ ОШИБКА: Не найден pyproject.toml" -ForegroundColor Red
    Write-Host "💡 Запустите скрипт из папки проекта" -ForegroundColor Yellow
    exit 1
}

# Активация виртуального окружения (если есть)
if (Test-Path ".venv\Scripts\Activate.ps1") {
    .\.venv\Scripts\activate
    Write-Host "✓ Виртуальное окружение активировано" -ForegroundColor Green
}

# Создание конфигурации pre-commit
$preCommitConfig = @"
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.13.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
        exclude: ^(pyproject\.toml|\.pre-commit-config\.yaml|\.gitignore|ruff\.toml|\.env|\.flake8)$
      - id: end-of-file-fixer
        exclude: ^(pyproject\.toml|\.pre-commit-config\.yaml|\.gitignore|ruff\.toml|\.env|\.flake8)$
      - id: check-yaml
      - id: check-added-large-files
        args: [--maxkb=5000]
      - id: check-merge-conflict
      - id: detect-private-key
"@

$preCommitConfig | Out-File -FilePath ".pre-commit-config.yaml" -Encoding UTF8
Write-Host "✓ Создан .pre-commit-config.yaml" -ForegroundColor Green

# Установка pre-commit hooks
pre-commit install
Write-Host "✓ Pre-commit hooks установлены" -ForegroundColor Green

# Автообновление конфигурации
Write-Host "🔄 Автообновление pre-commit..." -ForegroundColor Yellow
pre-commit autoupdate
Write-Host "✓ Конфигурация обновлена" -ForegroundColor Green

# Тестовый запуск
Write-Host "🧪 Тестовый запуск pre-commit..." -ForegroundColor Yellow
pre-commit run --all-files
Write-Host "✓ Pre-commit протестирован" -ForegroundColor Green

Write-Host "✅ Pre-commit успешно настроен!" -ForegroundColor Green
Write-Host "📋 Команды для работы:" -ForegroundColor Cyan
Write-Host "   pre-commit run --all-files           # Проверка всех файлов" -ForegroundColor White
Write-Host "   git add . && git commit -m 'message' # Коммит с проверкой" -ForegroundColor White
Write-Host "   pre-commit autoupdate               # Обновить хуки" -ForegroundColor White