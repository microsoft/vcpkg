set(PATCHES 0001-fix-for-vcpkg.patch)

if(VCPKG_TARGET_IS_UWP)
    list(APPEND PATCHES uwp-warnings.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libdatachannel
    REF f8ac6955e3cd673ac23a2172cd7dc42fc013b7b3 #v0.17.9
    SHA512 1042ca9b44b143bd41bec4abbeba35fdc2198e07d33d258c8dc2efcaf8f285737a7ea71c2f8d2cacfd03b37550047af4e20736dad4c7a9322bb6203a77a08727
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
