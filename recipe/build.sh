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
  # Check before
  echo "Before updating:"
  otool -L $PREFIX/lib/python$PY_VER/site-packages/gtsam/gtsam.cpython-${PY_VER//.}-darwin.so
  echo "Before updating unstable:"
  otool -L $PREFIX/lib/python$PY_VER/site-packages/gtsam_unstable/gtsam_unstable.cpython-${PY_VER//.}-darwin.so

  # Run install_name_tool
  install_name_tool -change $SRC_DIR/build/gtsam/libgtsam.4.dylib $PREFIX/lib/libgtsam.4.dylib $PREFIX/lib/python$PY_VER/site-packages/gtsam/gtsam.cpython-${PY_VER//.}-darwin.so
  install_name_tool -change $SRC_DIR/build/gtsam/libgtsam.4.dylib $PREFIX/lib/libgtsam.4.dylib $PREFIX/lib/python$PY_VER/site-packages/gtsam_unstable/gtsam_unstable.cpython-${PY_VER//.}-darwin.so
  install_name_tool -change $SRC_DIR/build/gtsam/libgtsam_unstable.4.dylib $PREFIX/lib/libgtsam_unstable.4.dylib $PREFIX/lib/python$PY_VER/site-packages/gtsam_unstable/gtsam_unstable.cpython-${PY_VER//.}-darwin.so

  # Check after
  echo "After updating:"
  otool -L $PREFIX/lib/python$PY_VER/site-packages/gtsam/gtsam.cpython-${PY_VER//.}-darwin.so
  echo "After updateing unstable:"
  otool -L $PREFIX/lib/python$PY_VER/site-packages/gtsam_unstable/gtsam_unstable.cpython-${PY_VER//.}-darwin.so
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]] && [[ "$(uname)" != "Darwin" ]]; then
  ninja check
fi
