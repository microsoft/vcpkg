project(tbb CXX)

file(GLOB SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/*)
file(COPY ${SOURCES} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/src)

include(${CMAKE_CURRENT_BINARY_DIR}/src/cmake/TBBBuild.cmake REQUIRED)
tbb_build(TBB_ROOT ${CMAKE_CURRENT_BINARY_DIR}/src MAKE_ARGS extra_inc=big_iron.inc)

set(SUBDIR ${CMAKE_CURRENT_BINARY_DIR}/tbb_cmake_build/tbb_cmake_build_subdir)
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(SUBDIR "${SUBDIR}_release")
else()
    set(SUBDIR "${SUBDIR}_debug")
endif()

file(GLOB OUTPUTS ${SUBDIR}/*.so.* ${SUBDIR}/*.so ${SUBDIR}/*.a ${SUBDIR}/*.dylib ${SUBDIR}/*.dylib.*)

install(FILES ${OUTPUTS} DESTINATION lib)
