# header-only library
message(WARNING "The port cpp-taskflow has been replaced with taskflow.")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taskflow/taskflow
    REF v2.4.0
    SHA512 0e970ad57b55fc392c72482284bee4e6907631d1ff6d0396b1d9eea9cd6ee9be222395837ad64769958ebe3267f40d959f4fcaf920cf646822a39e43cc0b3767
    HEAD_REF master
    PATCHES fix-compiler-error.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DTF_BUILD_EXAMPLES=OFF
        -DTF_BUILD_TESTS=OFF
        -DTF_BUILD_BENCHMARKS=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
