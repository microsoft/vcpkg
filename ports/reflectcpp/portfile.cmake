vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO munich-data-engineering/reflect-cpp
    REF "v${VERSION}"
    SHA512 8f0b72331a83ea241e10f72d67e4e1b865f2bd1c7dfd5de5743974fe9e5ac81493bf6ec602cde67c7ae2d5743d758f664c4299604bbf4fc5f1b9379149cea112
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
        csv                 REFLECTCPP_CSV
        flexbuffers         REFLECTCPP_FLEXBUFFERS
        msgpack             REFLECTCPP_MSGPACK
        parquet             REFLECTCPP_PARQUET
        toml                REFLECTCPP_TOML
        ubjson              REFLECTCPP_UBJSON
        xml                 REFLECTCPP_XML
        yaml                REFLECTCPP_YAML
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_DISABLE_FIND_PACKAGE_ament_cmake=ON
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
