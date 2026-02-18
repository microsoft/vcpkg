if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBXKBFILE_ARCHIVE
    URLS "https://www.x.org/releases/individual/lib/libxkbfile-${VERSION}.tar.xz"
    FILENAME "libxkbfile-${VERSION}.tar.xz"
    SHA512 772035b6bc1d692e8141e095fc2a8cf2ba7daed1d7148def862103160e0d7706f46865367befbbe4c777e7311b224d2cd4474f399d747b122dd395deac3e7cb7
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBXKBFILE_ARCHIVE}"
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
