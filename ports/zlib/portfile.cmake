# When this port is updated, the minizip port should be updated at the same time
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO madler/zlib
    REF v${VERSION}
    SHA512 67f3ce120210a69aa05cece6f76d5f45b50d947c095169f0d699732d0182d7d04aec1af56a3fc6bbcc2af91a57e099cd73980b17f7d96ad90aeabbeaafbf1cbc
    HEAD_REF master
    PATCHES
        0001-no-version-script-on-ohos.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ZLIB_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ZLIB_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DZLIB_BUILD_TESTING=OFF
        -DZLIB_BUILD_SHARED=${ZLIB_BUILD_SHARED}
        -DZLIB_BUILD_STATIC=${ZLIB_BUILD_STATIC}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/zlib")
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS)
    if(NOT VCPKG_TARGET_IS_MINGW)
        set(_rewrite_lib_prefix "lib")
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/zlib.pc" " -lz" " -l${_rewrite_lib_prefix}zs")
    else()
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/zlib.pc" " -lz" " -l${_rewrite_lib_prefix}z")
    endif()

    if(NOT VCPKG_BUILD_TYPE)
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/zlib.pc" " -lz" " -l${_rewrite_lib_prefix}zsd")
        else()
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/zlib.pc" " -lz" " -l${_rewrite_lib_prefix}zd")
        endif()
    endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/zconf.h" "ifdef ZLIB_DLL" "if 0")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/zlib/ZLIBConfig.cmake" [[_ZLIB_supported_components "shared" "static"]] [[_ZLIB_supported_components "static"]])
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/zlib/ZLIBConfig.cmake" [[if(NOT TARGET ZLIB::ZLIB)]] [[IF(FALSE)]])
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/zconf.h" "ifdef ZLIB_DLL" "if 1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/zlib/ZLIBConfig.cmake" [[_ZLIB_supported_components "shared" "static"]] [[_ZLIB_supported_components "shared"]])
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/zlib/ZLIBConfig.cmake" [[if(NOT TARGET ZLIB::ZLIBSTATIC)]] [[IF(FALSE)]])
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
