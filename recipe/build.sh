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

ninja install

# ninja python-install
cd python
if [ "$(uname)" == "Darwin" ]; then
  export DYLD_FALLBACK_LIBRARY_PATH="${DYLD_FALLBACK_LIBRARY_PATH}:${PREFIX}/lib"
else
  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${PREFIX}/lib"
fi
$PYTHON -m pip install .
# $PYTHON setup.py install --user --prefix=
cd ..

# if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
#   ninja check
# fi
