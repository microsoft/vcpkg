set(VCPKG_LIBRARY_LINKAGE "dynamic")

# We specify the Linux URL, but the only difference between the Windows/Linux packages are the included libraries
# which we re-build anyway.  There is no source only package provided or it would be preferred (and smaller).
vcpkg_download_distfile(ARCHIVE
    URLS "https://earth-info.nga.mil/php/download.php?file=wgs-mastertgz"
    FILENAME "geotrans-3.9-master-adf1935.tgz"
    SHA512 adf19357edc62681a2515e7210a752b0e09214b6ce69024e60150e0780059c08a9ab5a162a0562dbc37127438783a24bcde1adb88b559bc95ff9a5bea0eb8b39
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/geotrans-config.in.cmake"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/geotrans-config.cmake"
    @ONLY
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}" @ONLY)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/GEOTRANS3/docs/MSP_Geotrans_Terms_Of_Use.txt")

# Install the geo model data
file(COPY "${SOURCE_PATH}/data" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
