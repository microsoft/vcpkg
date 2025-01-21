# Shared library support is broken upstream (https://github.com/dartsim/dart/issues/1005#issuecomment-375406260)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dartsim/dart
    REF v${VERSION}
    SHA512 3c621245c5dc1bf26932c33c940e2b09aaebd1a15f3620616c60296f18a67e1044728543b4f640f92caf8f98295e350679b70eb11aecadea9e4a28aaf370ea75
    HEAD_REF main
    PATCHES
        disable_unit_tests_examples_and_tutorials.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDART_VERBOSE=ON
        -DDART_MSVC_DEFAULT_OPTIONS=ON
        -DDART_SKIP_DOXYGEN=ON
        -DDART_SKIP_FLANN=ON
        -DDART_SKIP_IPOPT=ON
        -DDART_SKIP_NLOPT=ON
        -DDART_SKIP_pagmo=ON
        -Durdfdom_headers_VERSION_MAJOR=1 # urdfdom-headers does not expose a header macro for its version.
        -Durdfdom_headers_VERSION_MINOR=0 # versions of at least 1.0.0 use std:: constructs in their ABI instead of boost:: ones.
        -Durdfdom_headers_VERSION_PATCH=0
    MAYBE_UNUSED_VARIABLES
        DART_MSVC_DEFAULT_OPTIONS
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/dart/cmake PACKAGE_NAME dart)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# only used for tests and examples (we removed the examples in share/doc above):
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dart/config.hpp" "#define DART_ROOT_PATH \"${SOURCE_PATH}/\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dart/config.hpp" "#define DART_DATA_PATH \"${SOURCE_PATH}/data/\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dart/config.hpp" "#define DART_DATA_LOCAL_PATH \"${SOURCE_PATH}/data/\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dart/config.hpp" "#define DART_DATA_GLOBAL_PATH                                                  \\\n  \"${CURRENT_PACKAGES_DIR}/share/doc/dart/data/\"" "")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
