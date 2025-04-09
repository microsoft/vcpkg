vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO getml/reflect-cpp
    REF "v${VERSION}"
    SHA512 035f93845eda11f3a9b804e0e6bf0312f277426966a7e1ac25722902d98b79a01f708bf3e608130633e8ac1ae512d544927cd9b94d4f19c794630404c3a92565 
    HEAD_REF main
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" REFLECTCPP_BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bson                REFLECTCPP_BSON
        capnproto           REFLECTCPP_CAPNPROTO
        cbor                REFLECTCPP_CBOR
        flexbuffers         REFLECTCPP_FLEXBUFFERS
        msgpack             REFLECTCPP_MSGPACK
        toml                REFLECTCPP_TOML
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
