# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adishavit/argh
    REF a1edee559757e076e570b8f6c2f555d8d00b373c
    SHA512 a100c7ff20ef9ed39d53efeac5507a6ed59fb99ccba36ac4b5f8f5aaac6782f8e951b2f26b9b50f6c6fdbc53b5bceaabbb9dd9b9539f968fc1037733342e17a6
    HEAD_REF master
    PATCHES
        remove_unnamespaced_license_file.patch # https://github.com/adishavit/argh/pull/51
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/${PORT})
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE ${CURRENT_PACKAGES_DIR}/README.md)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
