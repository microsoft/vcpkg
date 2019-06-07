# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arximboldi/immer
    REF v0.6.2
    SHA512 bcce4f26f8bb59d7d3fa5b3c2a5168c1aa9e0b257a09c8e393f13fdf399063e5303f92167fbf7faad9952d5ba4de8f9377993baff0f9917b51495f357f20f19e
    HEAD_REF master
    PATCHES
        fix-install.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DENABLE_SANITIZE=ON
    OPTIONS_RELEASE
        -DENABLE_SANITIZE=OFF
    OPTIONS
        -DENABLE_COVERAGE=OFF
        -DDISABLE_WERROR=OFF
        -DDISABLE_FREE_LIST=OFF
        -DDISABLE_THREAD_SAFETY=OFF
        -DENABLE_PYTHON=OFF
        -DENABLE_GUILE=OFF
        -DENABLE_BOOST_COROUTINE=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Immer)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
