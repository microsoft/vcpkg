vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kfrlib/kfr
    REF 9fc73247f43b303617329294ae264613df4dce71 # 4.2.1
    SHA512 c7dd4b1a0be436460973fb8a48bc6f2264a0f7d8d034ce88ccfd8328135f1492eab155023103a1461c2058eb6c79a6019b62d023dc5bc390ab4d2b43eac9c2d4
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        capi ENABLE_CAPI_BUILD
        dft ENABLE_DFT
        dft-np ENABLE_DFT_NP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_TESTS=OFF
        -DENABLE_ASMTEST=OFF
        -DREGENERATE_TESTS=OFF
        -DKFR_EXTENDED_TESTS=OFF
        -DSKIP_TESTS=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
