# No dynamic link for MSVC
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Orc/discount
    REF "v${VERSION}"
    SHA512 ca10220e4a4f8cd5c3e849873d24a61f8bcbb85f230fe554537d9cdd4e3d4d23c5f5fbc9c917da379000e331c40473038b481f5ac2db29dfa7011a634526688a
    HEAD_REF master
    PATCHES
      generate-blocktags-command.patch
      disable-deprecated-warnings.patch
)

set(GENERATE_BLOCKTAGS ON)
if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm" OR VCPKG_TARGET_ARCHITECTURE MATCHES "arm64" OR VCPKG_CMAKE_SYSTEM_NAME MATCHES "WindowsStore")
    set(GENERATE_BLOCKTAGS OFF)
endif()

if(NOT GENERATE_BLOCKTAGS)
    configure_file("${CURRENT_PORT_DIR}/blocktags" "${SOURCE_PATH}/blocktags" COPYONLY)
    message(STATUS "Copied blocktags")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cmake"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DDISCOUNT_ONLY_LIBRARY=ON
        -DGENERATE_BLOCKTAGS=${GENERATE_BLOCKTAGS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/discount)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/discount" RENAME copyright)

