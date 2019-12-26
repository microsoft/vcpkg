set(VCPKG_LIBRARY_LINKAGE "dynamic")

# We specify the Linux URL, but the only difference between the Windows/Linux packages are the included libraries
# which we re-build anyway.  There is no source only package provided or it would be preferred (and smaller).
vcpkg_download_distfile(ARCHIVE
    URLS "http://earth-info.nga.mil/GandG/geotrans/geotrans3.7/linux_dev.tgz"
    FILENAME "geotrans-3.7.tgz"
    SHA512 20bdc870026e95154f1d7f9560cbfa2c0b2dc39042aa544f093b502a0609121cb47df5729248e0d79ccf8f9908bf01bbcea8e777ae4f45e25472b7ce2bcb9742
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
