include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO docopt/docopt.cpp
    REF 4f491249e6def236937dbfac7602852e7d99aff8
    SHA512 d3a61f8d8a8c11723064f3405f03eb838a2ac9aa574f86771b1db89a2dd81996b639215fe5d4465343b893bf71502da178c7af8d883c112c1e45f43c17d473b7
    HEAD_REF master
    PATCHES
        001-fix-unresolved-symbol.patch
        002-fix-install-path.patch
        install-one-flavor.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITH_EXAMPLE=OFF
        -DWITH_TESTS=OFF
        -DUSE_BOOST_REGEX=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/docopt)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(READ ${CURRENT_PACKAGES_DIR}/include/docopt/docopt.h _contents)
    string(REPLACE "#ifdef DOCOPT_DLL" "#if 1" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/docopt/docopt.h "${_contents}")
endif()

# Header-only style when DOCOPT_HEADER_ONLY is defined
file(COPY
    ${SOURCE_PATH}/docopt.cpp
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/docopt)

# Handle copyright
file(INSTALL
    ${SOURCE_PATH}/LICENSE-MIT
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/docopt RENAME copyright)

vcpkg_copy_pdbs()
