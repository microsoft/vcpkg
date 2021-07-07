vcpkg_fail_port_install(ON_TARGET "uwp")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/commsdsl
    REF v3.6.3
    SHA512 0cb1573cd7dc000961a053601b85bd3c78183a0083fa654a97412c8024a3dc08bff58c833dea0af522a02888fbc198140d81615c7d8c7d5399871c2b0c2c43c5
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCOMMSDSL_NO_COMMS_CHAMPION=ON
        -DCOMMSDSL_NO_TESTS=ON
        -DCOMMSDSL_NO_WARN_AS_ERR=ON # remove on next version or on next version of boost
)
vcpkg_install_cmake()

vcpkg_copy_tools(
    TOOL_NAMES commsdsl2comms
    SEARCH_DIR ${CURRENT_PACKAGES_DIR}/bin
    AUTO_CLEAN
)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/LibCommsdsl/cmake TARGET_PATH share/LibCommsdsl)
# after fixing the following dirs are empty
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/LibCommsdsl")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/LibCommsdsl")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
