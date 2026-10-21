vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ebiggers/libdeflate
    REF "v${VERSION}"
    SHA512 06605eabce8635b82e03863c87b515696d08b8a1fc36b746b44b660989613d2ebd6ca1bb13dd0f88244846894dbf5a15169dd443c34dcda64e960fdbd08a8d3b
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        compression   LIBDEFLATE_COMPRESSION_SUPPORT
        decompression LIBDEFLATE_DECOMPRESSION_SUPPORT
        gzip          LIBDEFLATE_GZIP_SUPPORT
        zlib          LIBDEFLATE_ZLIB_SUPPORT
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LIBDEFLATE_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBDEFLATE_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBDEFLATE_BUILD_SHARED_LIB=${LIBDEFLATE_BUILD_SHARED}
        -DLIBDEFLATE_BUILD_STATIC_LIB=${LIBDEFLATE_BUILD_STATIC}
        -DLIBDEFLATE_BUILD_GZIP=OFF
        -DLIBDEFLATE_USER_SET_RELEASE_FLAGS=ON # Prevent wrong C flags modification
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libdeflate")
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libdeflate.h" "defined(LIBDEFLATE_DLL)" "1")
    elseif(NOT VCPKG_TARGET_IS_MINGW)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libdeflate.pc" " -ldeflate" " -ldeflatestatic")
        if(NOT VCPKG_BUILD_TYPE)
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libdeflate.pc" " -ldeflate" " -ldeflatestatic")
        endif()
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
