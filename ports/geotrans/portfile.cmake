set(VCPKG_LIBRARY_LINKAGE "dynamic")

message(WARNING "Download ${PORT} may take a several hours to complete!")
message(WARNING "Port ${PORT} source resides NGA US Government military ftp server with an extremely slow connection.")

# We specify the Linux URL, but the only difference between the Windows/Linux packages are the included libraries
# which we re-build anyway.  There is no source only package provided or it would be preferred (and smaller).
vcpkg_download_distfile(ARCHIVE
    URLS "ftp://ftp.nga.mil/pub2/gandg/website/wgs84/apps/geotrans/current-version/sw/master_version/master.tgz"
    FILENAME "geotrans-3.8-master.tgz"
    SHA512 359704ee9700762111006d126872feab9f644af0cebd433a657473347ea48f4eb172681f5f564fbca171bbf58fe0e8fb0829597403958770b7d22ad380afeac3
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