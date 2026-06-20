vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.xiph.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/icecast-libshout
    REF "v${VERSION}"
    HEAD_REF master
    SHA512 04dbb567f36269506becc3a50eb5fa263cbc308764c3fc1e59c3ab4833ef944479d0d35af33941214ff86899c40253a0ded095e5e217035848ce2694496720b5
    PATCHES
        0006-Handle-unhandled-enum-values-in-switch-statements.patch
        0007-fix-libshout-void-ptr-arithmetic-windows.patch
        0008-fix-libshout-ssize_t-windows.patch
        0009-fix-sys-paths-windows.patch
)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.xiph.org
    OUT_SOURCE_PATH SOURCE_PATH_COMMON
    REPO xiph/icecast-common
    REF 5de3e8b3b063002d8a9f52122e97f721e1742531
    HEAD_REF master
    SHA512 f064e2b2dd686c7647ba4c5afb9ca7e85b2015643d7a185cc319f47461aacc765e7f9b3e9576e09a73a8af0724a54fafdd7c064756d3c6e97329bb5f77806933
    PATCHES
        0001-fix-windows-compat-header.patch
        0002-fix-strings-h-windows.patch
        0003-fix-ssize_t-windows.patch
        0004-fix-void-ptr-arithmetic-windows.patch
        0005-Verify-port-number-length.patch
)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.xiph.org
    OUT_SOURCE_PATH SOURCE_PATH_M4
    REPO xiph/icecast-m4
    REF 57027c6cc3f8b26d59e9560b4ac72a1a06d643b9
    HEAD_REF master
    SHA512 67fe6fad8bf86990b5da311d729b9a746849f3d920c018112b4625b5e0d37a85444be16367967cb18a871c1ca1d679f5924ad3fc8547fbb30746b7e1f4b396bc
)

file(COPY ${SOURCE_PATH_COMMON}/ DESTINATION ${SOURCE_PATH}/src/common)
file(COPY ${SOURCE_PATH_M4}/ DESTINATION ${SOURCE_PATH}/m4)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
    set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_WARNINGS")
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_WARNINGS")
endif()

set(FEATURE_OPTIONS "")
if(NOT "speex" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "--disable-speex")
endif()
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    list(APPEND FEATURE_OPTIONS "--disable-examples")    
    list(APPEND FEATURE_OPTIONS "--disable-tools")
    list(APPEND FEATURE_OPTIONS "LIBS=-lws2_32 \$LIBS")
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    COPY_SOURCE
    OPTIONS
        ${FEATURE_OPTIONS}
)

# autoconf bakes CFLAGS=-O into the generated Makefile for MSVC, which overrides the
# environment CFLAGS set by vcpkg.
set(make_options_debug "")
set(make_options_release "")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
     list(APPEND make_options_debug "CFLAGS=\"$CFLAGS\"" "CXXFLAGS=\"$CXXFLAGS\"")
     list(APPEND make_options_release "CFLAGS=\"$CFLAGS\"" "CXXFLAGS=\"$CXXFLAGS\"")
endif()

vcpkg_make_install(
    OPTIONS_DEBUG ${make_options_debug}
    OPTIONS_RELEASE ${make_options_release}
)
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/shout.pc" "-lshout" "-llibshout")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/shout.pc" "-lshout" "-llibshout")
    endif()
endif()

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
