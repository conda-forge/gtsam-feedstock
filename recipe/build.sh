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

if [ "$(uname)" == "Darwin" ]; then
  # Detect Python implementation
  PYTHON_IMPL=$($PREFIX/bin/python -c "import platform; print(platform.python_implementation())")

  if [ "$PYTHON_IMPL" == "CPython" ]; then
    SO_SUFFIX="cpython-${PY_VER//.}-darwin.so"
  elif [ "$PYTHON_IMPL" == "PyPy" ]; then
    SO_SUFFIX="pypy39-pp73-darwin.so"
  fi

  SO_PATH_GTSAM="$PREFIX/lib/python$PY_VER/site-packages/gtsam/gtsam.$SO_SUFFIX"
  SO_PATH_UNSTABLE="$PREFIX/lib/python$PY_VER/site-packages/gtsam_unstable/gtsam_unstable.$SO_SUFFIX"
  install_name_tool -change $SRC_DIR/build/gtsam/libgtsam.4.dylib $PREFIX/lib/libgtsam.4.dylib $SO_PATH_GTSAM
  install_name_tool -change $SRC_DIR/build/gtsam/libgtsam.4.dylib $PREFIX/lib/libgtsam.4.dylib $SO_PATH_UNSTABLE
  install_name_tool -change $SRC_DIR/build/gtsam/libgtsam_unstable.4.dylib $PREFIX/lib/libgtsam_unstable.4.dylib $SO_PATH_UNSTABLE
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]] && [[ "$(uname)" != "Darwin" ]]; then
  ninja check
fi
