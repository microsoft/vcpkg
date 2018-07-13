include(vcpkg_common_functions)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  message(FATAL_ERROR "Apache Parquet only supports x64")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/parquet-cpp
    REF apache-parquet-cpp-1.4.0
    SHA512 a6c12e39dcae123ae1893f7fc32bae32e32a1943182b1c0c1c2726134ee4fa6470d73a6ff8e3ce312eeb250d7fa35c9b9f3c227a35ba0aa6f873ce3954217bed
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
    "${CMAKE_CURRENT_LIST_DIR}/all.patch"
)

SET(ENV{GTEST_HOME} ${CURRENT_INSTALLED_DIR})

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" PARQUET_BUILD_SHARED)
string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "static" PARQUET_BUILD_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
	-DTHRIFT_HOME=${CURRENT_INSTALLED_DIR}
	-DARROW_HOME=${CURRENT_INSTALLED_DIR}
    -DPARQUET_BUILD_STATIC=${PARQUET_BUILD_STATIC}
    -DPARQUET_BUILD_SHARED=${PARQUET_BUILD_SHARED}
	-DPARQUET_ARROW_LINKAGE=${VCPKG_LIBRARY_LINKAGE}
	-DPARQUET_BUILD_TOOLCHAIN=${CURRENT_INSTALLED_DIR}
	-DPARQUET_BOOST_USE_SHARED=${PARQUET_BUILD_SHARED}
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/parquet RENAME copyright)

# Put CMake files in the right place
file(INSTALL ${CURRENT_PACKAGES_DIR}/cmake/parquet-cppConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/parquet)
file(INSTALL ${CURRENT_PACKAGES_DIR}/cmake/parquet-cppConfigVersion.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/parquet RENAME parquet-cppConfigVersion-release.cmake)
file(INSTALL ${CURRENT_PACKAGES_DIR}/debug/cmake/parquet-cppConfigVersion.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/parquet RENAME parquet-cppConfigVersion-debug.cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
