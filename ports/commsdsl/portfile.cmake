vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/commsdsl
    REF v3.6.4
    SHA512 dd997bb063baf4e6bc15666539e8d3e8cf435cfda88e8b115b8a1568c8c77cc2ca6dbf1a77ae2fcf9b24f68cb35aa2ae583852cf887fbc85f74e868230374055
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DCOMMSDSL_NO_COMMS_CHAMPION=ON
        -DCOMMSDSL_BUILD_APPS=ON
        -DCOMMSDSL_INSTALL_APPS=ON
        -DCOMMSDSL_CHECKOUT_COMMS_CHAMPION=OFF
        -DCOMMSDSL_BUILD_UNIT_TESTS=OFF
        -DCOMMSDSL_WARN_AS_ERR=OFF
)
vcpkg_install_cmake()

vcpkg_copy_tools(
    TOOL_NAMES commsdsl2comms
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
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
