@echo off
setlocal

rem Ejecutar siempre desde la raiz del proyecto, aunque el .bat se abra desde otra carpeta.
cd /d "%~dp0.." || (
  echo ERROR: No se pudo acceder a la carpeta raiz del proyecto.
  exit /b 1
)

where flutter >nul 2>nul || (
  echo ERROR: Flutter no esta disponible en PATH.
  echo Agrega la carpeta bin de Flutter al PATH y vuelve a intentarlo.
  exit /b 1
)

if not exist "pubspec.yaml" (
  echo ERROR: No se encontro pubspec.yaml en la raiz del proyecto.
  exit /b 1
)

if not exist "config\demo.json" (
  echo ERROR: Falta config\demo.json.
  exit /b 1
)

call flutter pub get || exit /b 1
call flutter run --dart-define-from-file="config\demo.json"
set "exit_code=%errorlevel%"

endlocal & exit /b %exit_code%
