vcpkg_download_distfile(ARCHIVE
    URLS "http://developer.x-plane.com/wp-content/plugins/code-sample-generation/sample_templates/XPSDK303.zip"
    FILENAME "XPSDK303.zip"
    SHA512 23a1efc893fdb838ce90307ac2e1bf592b03880e9c7bf7aac51cf0d358816931b56a3d603e266f3c9041620190c689dc4d3b28b288bc39cf6e653db6f2125395
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

# create lib dir
if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_OSX)
    file(MAKE_DIRECTORY
        ${CURRENT_PACKAGES_DIR}/lib
        ${CURRENT_PACKAGES_DIR}/debug/lib
    )
endif()

# copy headers & sources
file(COPY ${SOURCE_PATH}/CHeaders/Widgets/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/CHeaders/Wrappers/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/CHeaders/XPLM/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# copy prebuilt libs
if(VCPKG_TARGET_IS_WINDOWS)
    file(COPY ${SOURCE_PATH}/Libraries/Win/XPLM_64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(COPY ${SOURCE_PATH}/Libraries/Win/XPWidgets_64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(COPY ${SOURCE_PATH}/Libraries/Win/XPLM_64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
    file(COPY ${SOURCE_PATH}/Libraries/Win/XPWidgets_64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
elseif (VCPKG_TARGET_IS_OSX)
    file(COPY ${SOURCE_PATH}/Libraries/Mac/ DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(COPY ${SOURCE_PATH}/Libraries/Mac/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
