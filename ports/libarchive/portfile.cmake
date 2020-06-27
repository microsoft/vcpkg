vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libarchive/libarchive
    REF cce09646b566c61c2debff58a70da780b8457883
    SHA512 3eef6844269ecb9c3b7c848013539529e6ef2d298b6ca6c3c939a2a2e39da98db36bd66eea8893224bc4318edc073639136fbca71b2b0bec65216562e8188749
    HEAD_REF master
    PATCHES
        fix-buildsystem.patch
        fix-dependencies.patch
        fix-lz4.patch
        fix-zstd.patch
        fix-cpu-set.patch
        disable-c4061.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    bzip2   ENABLE_BZip2
    libxml2 ENABLE_LIBXML2
    lz4     ENABLE_LZ4
    lzma    ENABLE_LZMA
    lzo     ENABLE_LZO
    openssl ENABLE_OPENSSL
    zstd    ENABLE_ZSTD
    # The below features should be added to CONTROL
    #pcre    ENABLE_PCREPOSIX
    #nettle  ENABLE_NETTLE
    #expat   ENABLE_EXPAT
    #libgcc  ENABLE_LibGCC
    #cng     ENABLE_CNG
    #tar     ENABLE_TAR # Tool build option?
    #cpio    ENABLE_CPIO # Tool build option?
    #cat     ENABLE_CAT # Tool build option?
    #xattr   ENABLE_XATTR # Tool support option?
    #acl     ENABLE_ACL # Tool support option?
    #iconv   ENABLE_ICONV # iconv support option?
    #libb2   ENABLE_LIBB2
)

if(FEATURES MATCHES "pcre")
else()
    list(APPEND FEATURE_OPTIONS -DPOSIX_REGEX_LIB=NONE)
endif()

list(APPEND FEATURE_OPTIONS -DENABLE_ZLIB=ON)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_PCREPOSIX=OFF
        -DENABLE_NETTLE=OFF
        -DENABLE_EXPAT=OFF
        -DENABLE_LibGCC=OFF
        -DENABLE_CNG=OFF
        -DENABLE_TAR=OFF
        -DENABLE_CPIO=OFF
        -DENABLE_CAT=OFF
        -DENABLE_XATTR=OFF
        -DENABLE_ACL=OFF
        -DENABLE_ICONV=OFF
        -DENABLE_TEST=OFF
        -DENABLE_WERROR=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

foreach(_feature IN LISTS FEATURE_OPTIONS)
    string(REPLACE "-D" "" _feature "${_feature}")
    string(REPLACE "=" ";" _feature "${_feature}")
    string(REPLACE "ON" "1" _feature "${_feature}")
    string(REPLACE "OFF" "0" _feature "${_feature}")
    list(GET _feature 0 _feature_name)
    list(GET _feature 1 _feature_status)
    set(${_feature_name} ${_feature_status})
endforeach()
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
foreach(HEADER ${CURRENT_PACKAGES_DIR}/include/archive.h ${CURRENT_PACKAGES_DIR}/include/archive_entry.h)
    file(READ ${HEADER} CONTENTS)
    string(REPLACE "(!defined LIBARCHIVE_STATIC)" "0" CONTENTS "${CONTENTS}")
    file(WRITE ${HEADER} "${CONTENTS}")
endforeach()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
