vcpkg_fail_port_install(ON_ARCH "x86" ON_TARGET "uwp")

# The project's CMakeLists.txt uses Python to select source files. Check if it is available in advance.
vcpkg_find_acquire_program(PYTHON3)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/fbgemm
    REF 51bc2ecc7086980fd9e6190163b04486cd37ac2a
    SHA512 43e59ff25ec9365061be6a8db7ec592f096e74897e338dd3e17401f2188986cf3b7e26f82f7c1e2adf34496fb32cb4b50d40731bee3bf9fa5b1f2ac92a09e671
    PATCHES
        fix-cmakelists.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_SANITIZER=OFF
        -DFBGEMM_BUILD_TESTS=OFF
        -DFBGEMM_BUILD_BENCHMARKS=OFF
        -DPYTHON_EXECUTABLE=${PYTHON3} # inject the path instead of find_package(Python)
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/${PORT})

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
