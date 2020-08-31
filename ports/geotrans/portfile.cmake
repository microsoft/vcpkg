set(VCPKG_LIBRARY_LINKAGE "dynamic")

message(WARNING "Download ${PORT} may take a few minutes, It depends on your network speed and connection.")

# We specify the Linux URL, but the only difference between the Windows/Linux packages are the included libraries
# which we re-build anyway.  There is no source only package provided or it would be preferred (and smaller).

vcpkg_download_distfile(ARCHIVE
    URLS "ftp://ftp.nga.mil/pub2/gandg/website/wgs84/apps/geotrans/current-version/sw/dev_version/linux_dev.tgz"
    FILENAME "geotrans-3.8.tgz"
    SHA512 a2261b5439d21781d1f57c9231805841d0eedd2298ede984321a9326c855568d44412f164ca3f0bd2dfdfe9c7503cf1c55575a178e9da163b49b0852673c201c
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/geotrans-config.in.cmake
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/geotrans-config.cmake
    @ONLY
)

configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT} @ONLY)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/GEOTRANS3/docs/MSP_Geotrans_Terms_Of_Use.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Install the geo model data
file(COPY ${SOURCE_PATH}/data DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})