vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libarchive/libarchive
    REF 227a4b9719a7fbeba6ba46e377ff7d953f405cd5      #v3.5.1
    SHA512 65adce56266a72ac25e3e36253ad66e4af4ba319a85d399362417a91e395adbc86caa39637a98c33af3a4147b03ca8836b647518b898346a5243f8cfc224ef32
    HEAD_REF master
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

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

foreach(HEADER ${CURRENT_PACKAGES_DIR}/include/archive.h ${CURRENT_PACKAGES_DIR}/include/archive_entry.h)
    file(READ ${HEADER} CONTENTS)
    string(REPLACE "(!defined LIBARCHIVE_STATIC)" "0" CONTENTS "${CONTENTS}")
    file(WRITE ${HEADER} "${CONTENTS}")
endforeach()

file(INSTALL ${CURRENT_PORT_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
