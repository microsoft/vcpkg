set(PATCHES fix-for-vcpkg.patch)

if(VCPKG_TARGET_IS_UWP)
    list(APPEND PATCHES uwp-warnings.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libdatachannel
    REF "v${VERSION}"
    SHA512 67119f6d1280593696f71dc550ceba1076066d0f55ebf10b527bf1c75e5e9571be18e5d9732e43a2aa4d5106a49a0676e70938d35d3eb4005cf17612f8836c52
    HEAD_REF master
    PATCHES 
        ${PATCHES}
        fix_dependency.patch
)
file(REMOVE "${SOURCE_PATH}/cmake/Modules/FindLibJuice.cmake")
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

if(srtp IN_LIST FEATURES)
    set(FIND_DEP_SRTP "find_dependency(libSRTP CONFIG)")
endif()

file(READ "${CURRENT_PACKAGES_DIR}/share/LibDataChannel/LibDataChannelConfig.cmake" DATACHANNEL_CONFIG)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/LibDataChannel/LibDataChannelConfig.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(Threads)
find_dependency(OpenSSL)
find_dependency(LibJuice)
find_dependency(plog CONFIG)
find_dependency(unofficial-usrsctp CONFIG)
${FIND_DEP_SRTP}
${DATACHANNEL_CONFIG}")


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
