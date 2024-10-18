vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ithewei/libhv
    REF "v${VERSION}"
    SHA512 06d3629cb4312610b2d7df279cd210a87bf76f92e606a2e8abcbd1f1a82bce060fd0984858859aa33d304b606e30349b0dca3eadaf26f452dd29eb1d52edce1d
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl WITH_OPENSSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_UNITTEST=OFF
        -DBUILD_STATIC=${BUILD_STATIC}
        -DBUILD_SHARED=${BUILD_SHARED}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libhv)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
