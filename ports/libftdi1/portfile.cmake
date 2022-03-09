vcpkg_download_distfile(ARCHIVE
    URLS "https://www.intra2net.com/en/developer/libftdi/download/libftdi1-1.5.tar.bz2"
    FILENAME "libftdi1-1.5.tar.bz2"
    SHA512 c525b2ab6aff9ef9254971ae7d57f3549a36a36875765c48f947d52532814a2a004de1232389d4fe824a8c8ab84277b08427308573476e1da9b7db83db802f6f
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF 1.5
    PATCHES
        libusb-fix.patch
        libconfuse-fix.patch
        win32.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/exports.def" DESTINATION "${SOURCE_PATH}/src")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DDOCUMENTATION=OFF
        -DEXAMPLES=OFF
        -DPYTHON_BINDINGS=OFF
        -DLINK_PYTHON_LIBRARY=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Boost=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Libintl=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_PythonLibs=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_PythonInterp=ON
        -DFTDI_EEPROM=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libftdi1)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
