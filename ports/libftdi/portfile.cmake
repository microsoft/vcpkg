vcpkg_download_distfile(ARCHIVE
    URLS "https://www.intra2net.com/en/developer/libftdi/download/libftdi-0.20.tar.gz"
    FILENAME "libftdi-0.20.tar.gz"
    SHA512 540e5eb201a65936c3dbabff70c251deba1615874b11ff27c5ca16c39d71c150cf61758a68b541135a444fe32ab403b0fba0daf55c587647aaf9b3f400f1dee7
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "0.20"
    PATCHES
        libusb-win32.patch
        shared-static.patch
        dont_use_lib64.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/exports.def" DESTINATION "${SOURCE_PATH}/src")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDOCUMENTATION=OFF
        -DEXAMPLES=OFF
        -DPYTHON_BINDINGS=OFF
        -DFTDIPP=OFF

        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Boost=ON

        "-DLIBUSB_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include"

        -DLIB_INSTALL_DIR=lib
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(COPY "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libftdi")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/libftdi/LICENSE" "${CURRENT_PACKAGES_DIR}/share/libftdi/copyright")

vcpkg_copy_pdbs()

# Delete pkgconfig files for ftdipp since we did -DFTDIPP=OFF above
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/ftdipp.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/ftdipp.pc")
