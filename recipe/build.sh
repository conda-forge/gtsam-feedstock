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
        -DCMAKE_MACOSX_RPATH=1 \
        -DGTSAM_BUILD_WITH_MARCH_NATIVE=OFF \
        -DGTSAM_BUILD_WITH_WERROR=OFF \
        -DGTSAM_BUILD_WITH_CCACHE=OFF \
        -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF \
        -DGTSAM_BUILD_TIMING_ALWAYS=OFF \
        -DGTSAM_USE_SYSTEM_EIGEN=ON \
        -DGTSAM_USE_SYSTEM_METIS=ON \
        -DGTSAM_USE_SYSTEM_PYBIND=ON \
        -DGTSAM_INSTALL_CPPUNITLITE=OFF \
        -DGTSAM_BUILD_PYTHON=ON \
        -DPython3_EXECUTABLE=$PYTHON \
        -DPython_EXECUTABLE=$PYTHON \
        -DPYTHON_EXECUTABLE=$PYTHON

ninja install -j2

cd python
$PYTHON -m pip install . --no-deps --no-build-isolation
cd ..

ninja all.tests
ctest --output-on-failure
