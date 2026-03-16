#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

echo "=== Portable CZI Viewer Launcher ==="

if [ ! -f "micromamba" ]; then
    echo "Step 1: Downloading the engine..."
    ARCH=$(uname -m)
    if [ "$ARCH" == "arm64" ]; then
        URL="https://micro.mamba.pm/api/micromamba/osx-arm64/latest"
    else
        URL="https://micro.mamba.pm/api/micromamba/osx-64/latest"
    fi
    
    curl -L# -o micromamba.tar.bz2 "$URL"
    tar -xjf micromamba.tar.bz2 bin/micromamba
    mv bin/micromamba ./micromamba
    rm -rf bin micromamba.tar.bz2
    chmod +x micromamba
fi

if [ -d "napari-runtime" ] && [ ! -f ".setup_done" ]; then
    echo "Previous setup was incomplete or broken. Cleaning up..."
    rm -rf napari-runtime mamba_root
fi

if [ ! -d "napari-runtime" ]; then
    echo "--------------------------------------------------------"
    echo "STEP 2: FIRST TIME SETUP"
    echo "Installing stable versions of napari and CZI plugins..."
    echo "This takes ~2 minutes. Please keep this window open."
    echo "--------------------------------------------------------"
    
    export MAMBA_ROOT_PREFIX="$DIR/mamba_root"
    
    ./micromamba create -y -p "$DIR/napari-runtime" -c conda-forge \
        python=3.10 \
        napari \
        napari-aicsimageio \
        napari-animation \
        napari-assistant \
        napari-threedee \
        aicspylibczi \
        pyqt \
        "tifffile<2023.3.15" \
        "imagecodecs<2024.1.1" \
        ffmpeg
        
    if [ $? -ne 0 ]; then
        echo "Error: Setup failed. Please check your internet connection."
        read -p "Press enter to exit..."
        exit 1
    fi
    touch .setup_done
    echo "Setup complete!"
fi

echo "Step 3: Launching CZI Viewer..."
echo "--------------------------------------------------------"

./napari-runtime/bin/python -m napari "$@"

echo ""
echo "Viewer closed."
read -p "Press enter to exit..."
