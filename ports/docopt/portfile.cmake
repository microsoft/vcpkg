vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO docopt/docopt.cpp
    REF 7476f8e56b4650aaeafb4e1cda2e5d8f01fddd97
    SHA512 6765e8a3a834ad75bd87effee5ac7e174482039d26015346b95d7d64e4e0097cc3f1f2e6fd9e3e5970bf4c5719095c0a3e5edfac18217913dc88fbe569d37ae8
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
