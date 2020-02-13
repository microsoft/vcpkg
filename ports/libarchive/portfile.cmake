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
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    bzip2   ENABLE_BZip2
    libxml2 ENABLE_LIBXML2
    lz4     ENABLE_LZ4
    lzma    ENABLE_LZMA
    lzo     ENABLE_LZO
    openssl ENABLE_OPENSSL
)

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
        -DENABLE_TEST=OFF
        -DENABLE_ICONV=OFF
        -DPOSIX_REGEX_LIB=NONE
        -DENABLE_WERROR=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
foreach(HEADER ${CURRENT_PACKAGES_DIR}/include/archive.h ${CURRENT_PACKAGES_DIR}/include/archive_entry.h)
    file(READ ${HEADER} CONTENTS)
    string(REPLACE "(!defined LIBARCHIVE_STATIC)" "0" CONTENTS "${CONTENTS}")
    file(WRITE ${HEADER} "${CONTENTS}")
endforeach()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libarchive)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libarchive/COPYING ${CURRENT_PACKAGES_DIR}/share/libarchive/copyright)
