string(REGEX REPLACE "^([0-9]+)[.]([1-9])\$" "\\1.0\\2" MEDIAINFO_VERSION "${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MediaArea/MediaInfoLib
    REF "v${MEDIAINFO_VERSION}"
    SHA512 861175390962c29e8cc2df6b3bae322db70b6fd068c79b232faf5c2119770ccbdf208abe07e16e69b95340d32bf406058a913d3a4ed986e6bb867b27dc31c8e0
    HEAD_REF master
    PATCHES
        dependencies.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/Source/ThirdParty/tinyxml2")

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        curl    VCPKG_LOCK_FIND_PACKAGE_CURL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Project/CMake"
    OPTIONS
        ${options}
        -DBUILD_ZENLIB=0
        -DBUILD_ZLIB=0
        -DCMAKE_REQUIRE_FIND_PACKAGE_PkgConfig=1
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME mediainfolib)
vcpkg_fixup_pkgconfig()
if(NOT VCPKG_BUILD_TYPE AND VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libmediainfo.pc" " -lmediainfo" " -lmediainfod")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/Source/ThirdParty/aes-gladman/aes.h"
    "${SOURCE_PATH}/Source/ThirdParty/sha1-gladman/sha1.h"
    "${SOURCE_PATH}/Source/ThirdParty/sha2-gladman/sha2.h"
    "${SOURCE_PATH}/Source/ThirdParty/hmac-gladman/hmac.h"
    "${SOURCE_PATH}/Source/ThirdParty/md5/md5.c"
    "${SOURCE_PATH}/Source/ThirdParty/tfsxml/tfsxml.h"
    "${SOURCE_PATH}/Source/ThirdParty/fmt/format.h"
    "${SOURCE_PATH}/Source/ThirdParty/base64/base64.h"
)
