mkdir build
cd build

if [ "$(uname)" == "Darwin" ]; then
  skiprpath="-DCMAKE_SKIP_RPATH=TRUE"
else
  skiprpath=""
fi

cmake .. ${CMAKE_ARGS} \
        ${skiprpath} \
        -GNinja \
        -DGTSAM_BUILD_WITH_MARCH_NATIVE=OFF \
        -DGTSAM_USE_SYSTEM_EIGEN=ON \
        -DGTSAM_USE_SYSTEM_METIS=ON \
        -DGTSAM_INSTALL_CPPUNITLITE=OFF \
        -DGTSAM_BUILD_PYTHON=ON \
        -DPython3_EXECUTABLE=$PYTHON \
        -DPython_EXECUTABLE=$PYTHON \
        -DPYTHON_EXECUTABLE=$PYTHON

ninja install -j2

cd python
$PYTHON -m pip install .
cd ..

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]] && [[ "$(uname)" != "Darwin" ]]; then
  ninja check
fi
