# Полная настройка проекта и pre-commit
param(
    [string]$ProjectName = "my_project",
    [string]$PythonVersion = "3.12",
    [string]$ProjectPath = "D:\Start_project"
)

# Создание проекта
.\setup-project.ps1 -ProjectName $ProjectName -PythonVersion $PythonVersion -ProjectPath $ProjectPath

# Настройка pre-commit
..\setup-precommit.ps1

Write-Host "🎉 Проект полностью настроен!" -ForegroundColor Green