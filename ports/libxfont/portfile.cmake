if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBXFONT2_ARCHIVE
    URLS "https://www.x.org/archive/individual/lib/libXfont2-${VERSION}.tar.xz"
    FILENAME "libXfont2-${VERSION}.tar.xz"
    SHA512 f703127df5d5b1093c9b73e019153ed7799523573d52e61d344209f0acfd4df42e11be12bdd1880479c47c2b70de581a4f2ef74e199e9b1ac438f426593d56b0
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBXFONT2_ARCHIVE}"
    PATCHES
        build.patch
        build2.patch
        configure.patch
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")
if(VCPKG_TARGET_IS_WINDOWS)
    string(APPEND VCPKG_CXX_FLAGS " /D_WILLWINSOCK_") # /showIncludes are not passed on so I cannot figure out which header is responsible for this
    string(APPEND VCPKG_C_FLAGS " /D_WILLWINSOCK_")
endif()
vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        --with-bzip2=yes
)

vcpkg_make_install()
if(VCPKG_TARGET_IS_WINDOWS)
    set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/xfont2.pc")
    file(READ "${_file}" _contents)
    string(REPLACE "-lm" "" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
    if(NOT VCPKG_BUILD_TYPE)
      set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/xfont2.pc")
      file(READ "${_file}" _contents)
      string(REPLACE "-lm" "" _contents "${_contents}")
      file(WRITE "${_file}" "${_contents}")
    endif()
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
