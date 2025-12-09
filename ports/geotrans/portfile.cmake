set(VCPKG_LIBRARY_LINKAGE "dynamic")

# We specify the Linux URL, but the only difference between the Windows/Linux packages are the included libraries
# which we re-build anyway.  There is no source only package provided or it would be preferred (and smaller).
vcpkg_download_distfile(ARCHIVE
    URLS "https://earth-info.nga.mil/php/download.php?file=wgs-mastertgz"
    FILENAME "geotrans-3.10-master-501325b.tgz"
    SHA512 501e25b80bd92a9651a6879ee42768abff9871cec3c79d457b0e74940e6fd3a477d98568dea0c4a4da2aa251ada11e17ab76edf5bcbdbde68e0e5cfe1813491f
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
