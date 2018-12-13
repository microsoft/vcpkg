include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO billyquith/ponder
    REF 3.0.0
    SHA512 b6ba1ce9fa0584b16085c56afb70e31f204a66b57193c1a4225bfe18abbda561bb71b3279dd0a4f1b21867b985ef5ce78c8e360f3fc654c61ce61c44d35c5f38
    HEAD_REF master
    PATCHES
        no-install-unused.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSES_RAPIDJSON=OFF
        -DUSES_RAPIDXML=OFF
        -DBUILD_TEST=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/ponder/cmake)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/lib/ponder
    ${CURRENT_PACKAGES_DIR}/lib/ponder)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING.txt ${CURRENT_PACKAGES_DIR}/share/ponder/copyright COPYONLY)
