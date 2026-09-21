mkdir build
cd build

cmake .. ${CMAKE_ARGS} \
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

# The pybind11 translation units (slam.cpp, navigation.cpp, ...) each need
# several GB to compile; two at once OOMs the 16 GB CI runners. build.bat
# already serializes for the same reason.
ninja install -j1

cd python
$PYTHON -m pip install . --no-deps --no-build-isolation
cd ..

ninja all.tests
ctest --output-on-failure
