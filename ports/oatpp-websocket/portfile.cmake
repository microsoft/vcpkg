set(OATPP_VERSION "0.19.12")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

message(STATUS "Building oatpp-websocket")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-websocket
    REF a71fa8dbe836a31a5727ebbe331cbdb275e94716 # 0.19.12
    SHA512 3e9fd165f8d00fb93ce019bde33fb687ade662776c2e1ab6f9edb756f13afceaa35c8c581ddba1a15dee8ae41a595b379dac5a28a77a83dbf252e3b9466d64df
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(OATPP_BUILD_SHARED_LIBRARIES_OPTION "ON")
else()
    set(OATPP_BUILD_SHARED_LIBRARIES_OPTION "OFF")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"
        "-DBUILD_SHARED_LIBS:BOOL=${OATPP_BUILD_SHARED_LIBRARIES_OPTION}"
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-websocket-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
