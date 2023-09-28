# No dynamic link for MSVC
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Orc/discount
    REF "v${VERSION}"
    SHA512 d86bfc6d3e11131622046418a1f54bd9dfa5f1233e510189cd2c89dc857da31e88ffbe6670cc506ca8b9763e8fb74ed215f1018f83e25767c77acb8a7c296b8a
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

