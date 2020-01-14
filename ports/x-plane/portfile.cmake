include(vcpkg_common_functions)

if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    message(FATAL_ERROR "the x-plane SDK cannot be built for the x86 architecture")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS http://developer.x-plane.com/wp-content/plugins/code-sample-generation/sample_templates/XPSDK301.zip
    FILENAME XPSDK301.zip
    SHA512 3044d606039be8230f35a5992d322d4c009b4056f8fb17e929a9f5c2204c084e2c83ddad10801b21727645ec957c8942b83938f81256ec3778dbe75df525e62a
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/debug/lib
)

file(COPY ${SOURCE_PATH}/CHeaders/Widgets/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/CHeaders/Wrappers/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/CHeaders/XPLM/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    file(COPY ${SOURCE_PATH}/Libraries/Win/XPLM_64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(COPY ${SOURCE_PATH}/Libraries/Win/XPWidgets_64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(COPY ${SOURCE_PATH}/Libraries/Win/XPLM_64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
    file(COPY ${SOURCE_PATH}/Libraries/Win/XPWidgets_64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
elseif (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    file(COPY ${SOURCE_PATH}/Libraries/Mac/XPLM.framework/ DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(COPY ${SOURCE_PATH}/Libraries/Mac/XPWidgets.framework/ DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(COPY ${SOURCE_PATH}/Libraries/Mac/XPLM.framework/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
    file(COPY ${SOURCE_PATH}/Libraries/Mac/XPWidgets.framework/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
endif()

file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/x-plane/ RENAME copyright)
