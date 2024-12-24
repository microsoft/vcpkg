string(REPLACE "." "_" MINIUPNPC_VERSION "${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO miniupnp/miniupnp
    REF "miniupnpd_${MINIUPNPC_VERSION}"
    SHA512 f461b57446d9086e8fc2caf6ef202a78d204b2580d6096aca63234fda53302cad03840b14cc0d8b68e9033049b749be46e35c3737cc6cbcd2ad30c59b737a390
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" MINIUPNPC_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" MINIUPNPC_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/miniupnpc"
    OPTIONS
    -DUPNPC_BUILD_STATIC=${MINIUPNPC_BUILD_STATIC}
    -DUPNPC_BUILD_SHARED=${MINIUPNPC_BUILD_SHARED}
    -DUPNPC_BUILD_TESTS=OFF
    -DUPNPC_BUILD_SAMPLE=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "/lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
else()
    file(GLOB RELEASE_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*.exe")
    if(${RELEASE_TOOLS})
        vcpkg_copy_tools(TOOL_NAMES ${RELEASE_TOOLS} AUTO_CLEAN)
    endif()
endif()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
