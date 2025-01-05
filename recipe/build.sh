mkdir build
cd build

if [ "$(uname)" == "Darwin" ]; then
  skiprpath="-DCMAKE_SKIP_RPATH=TRUE"
else
  skiprpath=""
fi

if [[ $target_platform == "linux-aarch64" ]]; then
  PYTHON_MAJOR=`echo $PY_VER|cut -f1 -d.`
  PYTHON_MINOR=`echo $PY_VER|cut -f2 -d.`
  MODULE_EXT="-DPYTHON_MODULE_EXTENSION=.cpython-${PYTHON_MAJOR}${PYTHON_MINOR}-aarch64-linux-gnu.so"
  echo "Use MODULE_EXT=$MODULE_EXT"
fi

cmake .. ${CMAKE_ARGS} \
        ${skiprpath} \
        ${MODULE_EXT} \
        -GNinja \
        -DCMAKE_MACOSX_RPATH=1 \
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
