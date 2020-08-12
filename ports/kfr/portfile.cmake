vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kfrlib/kfr
    REF 1f9706197abfcd4b4ec19ded3ce37b70ebd9a223
    SHA512 901c6984a46a7abcc28adf9397759156a9e8d173e028c236ab423568ed20b3a3efe207be9660c961539c73a2767afaedcd76133304f542d3299353942cf13f5e
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    capi ENABLE_CAPI_BUILD
    dft ENABLE_DFT
    dft-np ENABLE_DFT_NP
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_TESTS=OFF
        -DENABLE_ASMTEST=OFF
        -DREGENERATE_TESTS=OFF
        -DKFR_EXTENDED_TESTS=OFF
        -DSKIP_TESTS=ON
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
