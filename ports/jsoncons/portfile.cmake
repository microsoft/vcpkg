include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO danielaparker/jsoncons
    REF v0.136.0
    SHA512 3ab6c4a6142469f7ba9f7b2dd5d2b2d7ed1e65811c389c60b3ce2586284f3d258db0ce80e90466c869c49514bb8df8092318736784eed75f165a26d0e0a5f670
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/jsoncons)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/jsoncons/LICENSE ${CURRENT_PACKAGES_DIR}/share/jsoncons/copyright)
