set(VCPKG_LIBRARY_LINKAGE "dynamic")

# We specify the Linux URL, but the only difference between the Windows/Linux packages are the included libraries
# which we re-build anyway.  There is no source only package provided or it would be preferred (and smaller).
vcpkg_download_distfile(ARCHIVE
    URLS "https://earth-info.nga.mil/php/download.php?file=wgs-mastertgz"
    FILENAME "geotrans-3.9-master.tgz"
    SHA512 b0bd5ca6eb584eebf0adc89eb86ec949f372bb4ea92c559f74f2055b0f121369b3d8de0bcff7b7db9abc57ac5a129d5c283d67f098e4af12d91b41747a76e541
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
