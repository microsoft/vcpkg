if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/leveldb
    REF "${VERSION}"
    SHA512 ac15eac29387b9f702a901b6567d47a9f8c17cf5c7d8700a77ec771da25158c83b04959c33f3d4de7a3f033ef08f545d14ba823a8d527e21889c4b78065b0f84
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
        fix-util-install.patch
)

file(COPY "${CURRENT_PORT_DIR}/leveldbConfig.cmake.in" DESTINATION "${SOURCE_PATH}/cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        crc32c WITH_CRC32C
        snappy WITH_SNAPPY
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLEVELDB_BUILD_TESTS=OFF
        -DLEVELDB_BUILD_BENCHMARKS=OFF
        -DHAVE_TCMALLOC=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/leveldb")


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
