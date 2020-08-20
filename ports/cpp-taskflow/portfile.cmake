# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taskflow/taskflow
    REF v2.5.0
    SHA512 49f38a14a207db085a2e3581b3698cdb3be4fa65c11194db454bd2fb65da2d744347c6a10a7a903b04cc2dd5cac65ef389d400c66d2a23521c3bbe2283357890
    HEAD_REF master
    PATCHES fix-compiler-error.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DTF_BUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DTF_BUILD_BENCHMARKS=OFF
        -DCMAKE_CUDA_COMPILER=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
