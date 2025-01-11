@echo off
SETLOCAL

:: Set the image name
SET IMAGE_NAME=flashx-app

:: Check if Docker is running
docker info >nul 2>&1
IF ERRORLEVEL 1 (
    echo Docker is not running. Please start Docker Desktop and try again.
    exit /b 1
)

:: Check if the image exists locally
docker image inspect %IMAGE_NAME% >nul 2>&1
IF ERRORLEVEL 1 (
    echo Image '%IMAGE_NAME%' not found locally. Attempting to build it...

    :: Check if Dockerfile exists
    IF EXIST flashx_dockerfile (
        docker build -t %IMAGE_NAME% -f flashx_dockerfile .
        IF ERRORLEVEL 1 (
            echo Failed to build the Docker image. Please check your Dockerfile and try again.
            exit /b 1
        )
    ) ELSE (
        echo Dockerfile not found. Please ensure the file 'flashx_dockerfile' is in the current directory.
        exit /b 1
    )
)

:: Set the volume mount path (adjust as needed)
SET VOLUME_MOUNT=C:\Users\%USERNAME%\flashx:/home/flashuser/flashx/Flash-X/desktop

:: Run the Docker container
docker run --rm -it --name flashx-container --hostname buildkitsandbox -v %VOLUME_MOUNT% %IMAGE_NAME%
IF ERRORLEVEL 1 (
    echo Failed to run the Docker container. Please check your settings and try again.
    exit /b 1
)

ENDLOCAL

