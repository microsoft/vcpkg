vcpkg_fail_port_install(ON_ARCH "x86" ON_TARGET "uwp")

# The project's CMakeLists.txt uses Python to select source files. Check if it is available in advance.
vcpkg_find_acquire_program(PYTHON3)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pytorch/fbgemm
    REF 975e41df8170115129abc524c225ddb88ec686dd
    SHA512 2ee8b1464b29cd7ceb36665188f1b03e20d2c476b74fd81d2e3104a8e8f87196eca4497e7cb507eac576e717df8f306d05cc81a7122ed046814a171f6cfbe7b1
    PATCHES
        fix-cmakelists.patch
        update-asmjit-usage.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_SANITIZER=OFF
        -DFBGEMM_BUILD_TESTS=OFF
        -DFBGEMM_BUILD_BENCHMARKS=OFF
        -DPYTHON_EXECUTABLE=${PYTHON3} # inject the path instead of find_package(Python) while configuration
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/${PORT} TARGET_PATH share/${PORT})

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
