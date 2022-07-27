mkdir build
cd build

cmake ^
    -GNinja ^
    -DGTSAM_BUILD_WITH_MARCH_NATIVE=OFF ^
    -DGTSAM_USE_SYSTEM_EIGEN=ON ^
    -DGTSAM_INSTALL_CPPUNITLITE=OFF ^
    -DGTSAM_BUILD_PYTHON=ON ^
    -DBoost_NO_BOOST_CMAKE=ON ^
    -DPython3_EXECUTABLE=%PYTHON% ^
    -DPython_EXECUTABLE=%PYTHON% ^
    -DPYTHON_EXECUTABLE=%PYTHON% ^
    %SRC_DIR%
    
if errorlevel 1 exit 1

ninja install

if errorlevel 1 exit 1

@rem ninja check
