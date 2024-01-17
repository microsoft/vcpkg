set(PATCHES fix-for-vcpkg.patch)

if(VCPKG_TARGET_IS_UWP)
    list(APPEND PATCHES uwp-warnings.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libdatachannel
    REF "v${VERSION}"
    SHA512 63551a9f2ce8de7f7aba13b2114418d3d705a6c190d91eac7cf6deba93ccbe9bda053000feb7ac109d538646c77da62b31686a58f83d752f191cac3a015f2d69
    HEAD_REF master
    PATCHES 
        ${PATCHES}
        fix_dependency.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" DATACHANNEL_STATIC_LINKAGE)

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
        -DPREFER_SYSTEM_LIB=ON
        -DNO_EXAMPLES=ON
        -DNO_TESTS=ON
        -DDATACHANNEL_STATIC_LINKAGE=${DATACHANNEL_STATIC_LINKAGE}
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
find_dependency(plog CONFIG)
find_dependency(libSRTP CONFIG)
${DATACHANNEL_CONFIG}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
