vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libdatachannel
    REF 267fdc190bcd276aacf45e4cd5ab8a51541161e8 #v0.15.1
    SHA512 333b1308b9f620326aa3b1af30aed8be2011c3a5a7d850e94476b8a14f696cef4cc815fda57e7a205cc264a077b7d1fa403ff1354364aae58651cdb0324c951b
    HEAD_REF master
    PATCHES
        0001-fix-for-vcpkg.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        stdcall CAPI_STDCALL
    INVERTED_FEATURES
        ws NO_WEBSOCKET
        srtp NO_MEDIA
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DUSE_SYSTEM_SRTP=ON
        -DNO_EXAMPLES=ON
        -DNO_TESTS=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME LibDataChannel CONFIG_PATH lib/cmake/LibDataChannel)
vcpkg_fixup_pkgconfig()

file(READ "${CURRENT_PACKAGES_DIR}/share/LibDataChannel/LibDataChannelConfig.cmake" DATACHANNEL_CONFIG)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/LibDataChannel/LibDataChannelConfig.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(Threads)
find_dependency(OpenSSL)
find_dependency(libjuice)
${DATACHANNEL_CONFIG}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)