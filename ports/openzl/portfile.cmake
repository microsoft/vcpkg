vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/openzl
    REF v${VERSION}
    SHA512 faac20161316b9d0383101c6ddc54a2e42bab75036a3a4ca0a8aa54a0860890723011078532adb199696d532d3b84811912fd6842e8824b716a7d1a4db5aca19
    HEAD_REF main
    PATCHES
        fix-dependencies.patch
)

file(REMOVE "${SOURCE_PATH}/src/openzl/shared/xxhash.h")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/xxhash-wrapper.h" DESTINATION "${SOURCE_PATH}/src/openzl/shared")
file(RENAME "${SOURCE_PATH}/src/openzl/shared/xxhash-wrapper.h" "${SOURCE_PATH}/src/openzl/shared/xxhash.h")

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
if(VCPKG_DETECTED_CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    message(FATAL_ERROR "MSVC is not supported; use clang-cl")
endif()

set(OPENZL_BUILD_SHARED_LIBS OFF)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(OPENZL_BUILD_SHARED_LIBS ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SHARED_LIBS=${OPENZL_BUILD_SHARED_LIBS}
        -DOPENZL_BUILD_SHARED_LIBS=${OPENZL_BUILD_SHARED_LIBS}
        -DOPENZL_INSTALL_CMAKEDIR=share/${PORT}
        -DOPENZL_BUILD_ALL=OFF
        -DOPENZL_BUILD_CPP=ON
        -DOPENZL_BUILD_CUSTOM_PARSERS=OFF
        -DOPENZL_BUILD_TOOLS=OFF
        -DOPENZL_BUILD_CLI=OFF
        -DOPENZL_BUILD_EXAMPLES=OFF
        -DOPENZL_BUILD_TESTS=OFF
        -DOPENZL_BUILD_BENCHMARKS=OFF
        -DOPENZL_BUILD_PARQUET_TOOLS=OFF
        -DOPENZL_BUILD_PYTHON_EXT=OFF
        -DOPENZL_BUILD_PYTHON_EXT_TESTS=OFF
        -DOPENZL_ALLOW_INTROSPECTION=ON
        -DOPENZL_INSTALL=ON
        -DOPENZL_CPP_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
