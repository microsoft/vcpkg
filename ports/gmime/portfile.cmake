vcpkg_download_distfile(ARCHIVE
    URLS https://github.com/jstedfast/gmime/releases/download/${VERSION}/gmime-${VERSION}.tar.xz
    FILENAME "gmime-${VERSION}.tar.xz"
    SHA512 cafb89854b2441508bf940fd6f991739d30fb137b8928ad33e8e4d2a0293a6460e4d1318e73c3ee9e5a964b692f36e7a4eb5f2930c6998698bd9edf866629655
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        subdirs.diff
        msvc-ssize_t.diff
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/aclocal/\"") # for glib
set(ENV{GTKDOCIZE} true)

vcpkg_list(SET options)
set(iconv_detect_h "${CURRENT_HOST_INSTALLED_DIR}/share/${PORT}/iconv-detect-${VCPKG_CMAKE_SYSTEM_NAME}.h")
if(EXISTS "${iconv_detect_h}")
    vcpkg_list(APPEND options "ac_cv_have_iconv_detect_h=yes")
elseif(VCPKG_CROSSCOMPILING)
    vcpkg_list(APPEND options "ac_cv_have_iconv_detect_h=no")
endif()

if("crypto" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-crypto")
else()
    vcpkg_list(APPEND options "--disable-crypto")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    ADD_BIN_TO_PATH  # for iconv-detect
    OPTIONS
        ${options}
        --disable-glibtest
        --disable-introspection
        --disable-vala
)

if(EXISTS "${iconv_detect_h}")
    file(COPY_FILE "${iconv_detect_h}" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/iconv-detect.h")
    if(NOT VCPKG_BUILD_TYPE)
        file(COPY_FILE "${iconv_detect_h}" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/iconv-detect.h")
    endif()
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(COPY "${SOURCE_PATH}/build/vs2017/unistd.h" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    if(NOT VCPKG_BUILD_TYPE)
        file(COPY "${SOURCE_PATH}/build/vs2017/unistd.h" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    endif()
endif()

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(NOT VCPKG_CROSSCOMPILING)
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/iconv-detect.h"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
        RENAME "iconv-detect-${VCPKG_CMAKE_SYSTEM_NAME}.h"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
