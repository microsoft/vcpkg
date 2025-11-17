vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/TinyEXIF
    REF ${VERSION}
    SHA512 1285566c70f4de3c882a433d65595f18d848ecf8e9b16e1ea3aa7a1773fb70ba090c7cc726238132cccfc403c3750950175c675d25206be38cddb64f16193795
    HEAD_REF 1.0.4
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)
if(BUILD_STATIC_LIBS)
    set(_BUILD_SHARED_LIBS OFF)
else()
    set(_BUILD_SHARED_LIBS ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SHARED_LIBS=${_BUILD_SHARED_LIBS}
        -DBUILD_DEMO=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/TinyEXIF)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
