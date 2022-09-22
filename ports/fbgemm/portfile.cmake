# The project's CMakeLists.txt uses Python to select source files. Check if it is available in advance.
vcpkg_find_acquire_program(PYTHON3)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/fbgemm
    REF 5876514306de2586e617b6ff1212eacf25114a49
    SHA512 103f708e6705be9df653076d3b0a47405c5e5f31649bbed215a006a1434d95b89130175ae7633f088ecd3d7ab8e03d88a65ae8843b1372c69f4d49366a80890b
    PATCHES
        fix-cmakelists.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_SANITIZER=OFF
        -DFBGEMM_BUILD_TESTS=OFF
        -DFBGEMM_BUILD_BENCHMARKS=OFF
        -DPYTHON_EXECUTABLE=${PYTHON3} # inject the path instead of find_package(Python)
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME fbgemmLibrary CONFIG_PATH share/cmake/${PORT})

# this internal header is required by pytorch
file(INSTALL     "${SOURCE_PATH}/src/RefImplementations.h"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include/fbgemm/src")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
