cmake_minimum_required(VERSION 3.30)
project(fluidsynth-test LANGUAGES C CXX)

find_package(FluidSynth CONFIG REQUIRED)

add_executable(main main.c)
target_link_libraries(main PRIVATE FluidSynth::libfluidsynth)

find_package(PkgConfig REQUIRED)
pkg_check_modules(fluidsynth_pc fluidsynth REQUIRED IMPORTED_TARGET)

add_executable(main-pkconfig main.c)
target_link_libraries(main-pkconfig PRIVATE PkgConfig::fluidsynth_pc)
set_target_properties(main-pkconfig PROPERTIES LINKER_LANGUAGE CXX)
