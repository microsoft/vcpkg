include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO woollybah/gppanel
    REF 5ef9674d893bbf5e17da66841cbc6aeeef051b25
    SHA512 a52eb5c4d9065e29d84374e9c484bae14cf7ff9a80fe6b025be108942a6c4683dd7f64830f78f0f7d45971f930df68f58dadf7c3915178e8908dd220d06a1e2c
    HEAD_REF master
    PATCHES 00001-fix-build.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

# Shamelessly stolen from plplot ("vcpkg/buildtrees/plplot/src/5.13.0-d50d469362/cmake/modules")
file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindwxWidgets.cmake DESTINATION ${SOURCE_PATH}/cmake/modules)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_MODULE_PATH=${SOURCE_PATH}/cmake/modules
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/gpPanel)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/gpPanel/copyright COPYONLY)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/gpPanel)
