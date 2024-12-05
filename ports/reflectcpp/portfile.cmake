vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO getml/reflect-cpp
    REF "v${VERSION}"
    SHA512 9c5034e6d964a1ae817cb14e4cd0d19ccb69e703affd8c070105ace63f2f0f59079ae450c1de7a19d3e35faf471dcd5e4bbd56cd3f0594f23059dfc45f622ac0 
    HEAD_REF main
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" REFLECTCPP_BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bson                REFLECTCPP_BSON
        flexbuffers         REFLECTCPP_FLEXBUFFERS
        msgpack             REFLECTCPP_MSGPACK
        ubjson              REFLECTCPP_UBJSON
        xml                 REFLECTCPP_XML
        yaml                REFLECTCPP_YAML
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DREFLECTCPP_BUILD_TESTS=OFF
        -DREFLECTCPP_BUILD_SHARED=${REFLECTCPP_BUILD_SHARED}
        -DREFLECTCPP_USE_BUNDLED_DEPENDENCIES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/${PORT}"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
