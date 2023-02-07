set(PATCHES 0001-fix-for-vcpkg.patch)

if(VCPKG_TARGET_IS_UWP)
    list(APPEND PATCHES uwp-warnings.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libdatachannel
    REF 2c6ef2053c6d28a66c16d0dae54e432750753575 #v0.17.11
    SHA512 b65cff5a7cb274fe4651c2cd395533c50eb2959192596e6ac7017af40c93d75cbc83ad86f8810e728b33d8d0b5993eddba4eac8644a603c5e641bf7cc4b87425
    HEAD_REF master
    PATCHES
        ${PATCHES}
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
        -DUSE_SYSTEM_JUICE=ON
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
find_dependency(LibJuice)
${DATACHANNEL_CONFIG}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
