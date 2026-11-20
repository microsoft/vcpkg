if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBXFONT2_ARCHIVE
    URLS "https://www.x.org/archive/individual/lib/libXfont2-${VERSION}.tar.xz"
    FILENAME "libXfont2-${VERSION}.tar.xz"
    SHA512 46ee0d4859cafd691b69936ad416d83e3867ea93aee05419fec15cbdabab42f3c9eccef12eb150cfcd8ced78a65f3dcd81532fae755d16e8b43ea82266f8a058
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
