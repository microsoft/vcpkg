# Shared library support is broken upstream (https://github.com/dartsim/dart/issues/1005#issuecomment-375406260)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(WIN_PR_PATCH
    URLS "https://github.com/dartsim/dart/pull/1666.diff"
    FILENAME dartsim-pr-1666.patch
    SHA512 1f1055c3be60ed6efcf2731950c55f1022e2a34e8bae9641c856e85d41106399fc761916159a58175da9413497693aa7622f7f77f6d0756ff4f466052087d5bb
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dartsim/dart
    REF d28c2860dcf709c95e18a3cc14f4b1ff091f46b3
    SHA512 0e818c6d081dc1ded30d929d7e904237056ad4607ff3cd02cc86137ecb100a93eafa6b855e760bd3c5d3bcc4afe8a1eae367b6c61daf7d00ab3028149e005efa
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
        -DDART_SKIP_OPENGL=ON
        -DDART_SKIP_pagmo=ON
        -Durdfdom_headers_VERSION_MAJOR=1
        -Durdfdom_headers_VERSION_MINOR=1
        -Durdfdom_headers_VERSION_PATCH=0
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
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dart/config.hpp" "#define DART_DATA_GLOBAL_PATH \"${CURRENT_PACKAGES_DIR}/share/doc/dart/data/\"" "")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
