cmake_minimum_required(VERSION 3.16)
project(gtsam_link_test LANGUAGES CXX)

# Do not call find_package(Threads) here: GTSAMConfig.cmake must do it.
find_package(GTSAM REQUIRED)

add_executable(gtsam_link_test main.cpp)
target_link_libraries(gtsam_link_test PRIVATE gtsam)

enable_testing()
add_test(NAME gtsam_link_test COMMAND gtsam_link_test)
