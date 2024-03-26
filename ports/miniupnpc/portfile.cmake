string(REPLACE "." "_" MINIUPNPC_VERSION "${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO miniupnp/miniupnp
    REF "miniupnpc_${MINIUPNPC_VERSION}"
    SHA512 f92fcd066cff7c43d00d23170473b309f4836a9b9ed10bbb39dfd42fe20fc0c3f7bcf82acd23fea5f84aa88ac60d2cba319f4829d466cfebac8bb8596adb871a
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
    file(GLOB DEBUG_TOOLS "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
    file(GLOB RELEASE_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*.exe")
    file(
        INSTALL ${RELEASE_TOOLS}
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
    )
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(REMOVE ${DEBUG_TOOLS} ${RELEASE_TOOLS})
endif()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
