mkdir build
cd build

cmake ^
    -GNinja ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DGTSAM_BUILD_UNSTABLE:OPTION=ON ^
    -DGTSAM_BUILD_STATIC_LIBRARY=OFF ^
    -DGTSAM_BUILD_WITH_MARCH_NATIVE=OFF ^
    -DGTSAM_USE_SYSTEM_EIGEN=ON ^
    -DGTSAM_INSTALL_CPPUNITLITE=OFF ^
    -DGTSAM_BUILD_PYTHON=ON ^
    -DGTSAM_USE_SYSTEM_METIS=ON ^
    -DGTSAM_USE_SYSTEM_PYBIND=ON ^
    -DGTSAM_BUILD_WITH_WERROR=OFF ^
    -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF ^
    -DGTSAM_BUILD_TIMING_ALWAYS=OFF ^
    -DBoost_LIBRARYDIR:FILEPATH="%LIBRARY_PREFIX%\lib" ^
    -DBoost_INCLUDEDIR:FILEPATH="%LIBRARY_PREFIX%\include" ^
    -DBoost_USE_STATIC_LIBS:BOOL=OFF ^
    -DGTSAM_CMAKE_CONFIGURATION_TYPES="Release" ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DPython3_EXECUTABLE=%PYTHON% ^
    -DPython_EXECUTABLE=%PYTHON% ^
    -DPYTHON_EXECUTABLE=%PYTHON% ^
    %SRC_DIR%
if errorlevel 1 exit 1

ninja install -j1
if errorlevel 1 exit 1

cd python
python -m pip install . -vv
if errorlevel 1 exit 1
cd ..

copy python\gtsam\gtsam*.pyd "%SP_DIR%\gtsam\"
if errorlevel 1 exit 1
copy python\gtsam_unstable\gtsam_unstable*.pyd "%SP_DIR%\gtsam_unstable\"
if errorlevel 1 exit 1

@rem The test suite is not run on Windows. 19 of the 385 tests segfault before
@rem main, among them testUnit3, testCalibratedCamera, testPinholeCamera,
@rem testTriangulation and testManifoldEKF. They pass on linux and osx, and they
@rem also pass on macOS when built the way MSVC builds them (one executable per
@rem test group), so this is specific to Windows rather than to the packaging.
@rem Re-enable with `ninja all.tests` and `ctest --output-on-failure` once that
@rem is fixed upstream; the unix builds run the suite already.
