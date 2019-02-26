include(vcpkg_common_functions)

if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    message(FATAL_ERROR "the x-plane SDK cannot be built for the x86 architecture")
endif()

vcpkg_download_distfile(
    OUT_SOURCE_PATH
    URLS http://developer.x-plane.com/wp-content/plugins/code-sample-generation/sample_templates/XPSDK301.zip
    FILENAME XPSDK301.zip
    SHA512 3044d606039be8230f35a5992d322d4c009b4056f8fb17e929a9f5c2204c084e2c83ddad10801b21727645ec957c8942b83938f81256ec3778dbe75df525e62a
)

vcpkg_extract_source_archive(
    ${OUT_SOURCE_PATH} ${CURRENT_PACKAGES_DIR}/temp/
)

file(MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/debug/lib
)

file(COPY ${CURRENT_PACKAGES_DIR}/temp/SDK/CHeaders/Widgets/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${CURRENT_PACKAGES_DIR}/temp/SDK/CHeaders/Wrappers/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${CURRENT_PACKAGES_DIR}/temp/SDK/CHeaders/XPLM/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    file(COPY ${CURRENT_PACKAGES_DIR}/temp/SDK/Libraries/Win/XPLM_64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(COPY ${CURRENT_PACKAGES_DIR}/temp/SDK/Libraries/Win/XPWidgets_64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(COPY ${CURRENT_PACKAGES_DIR}/temp/SDK/Libraries/Win/XPLM_64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
    file(COPY ${CURRENT_PACKAGES_DIR}/temp/SDK/Libraries/Win/XPWidgets_64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
elseif (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    file(COPY ${CURRENT_PACKAGES_DIR}/temp/SDK/Libraries/Mac/XPLM.framework/ DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(COPY ${CURRENT_PACKAGES_DIR}/temp/SDK/Libraries/Mac/XPWidgets.framework/ DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(COPY ${CURRENT_PACKAGES_DIR}/temp/SDK/Libraries/Mac/XPLM.framework/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
    file(COPY ${CURRENT_PACKAGES_DIR}/temp/SDK/Libraries/Mac/XPWidgets.framework/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
endif()

# Handle copyright
file(COPY ${CURRENT_PACKAGES_DIR}/temp/SDK/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/x-plane/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/x-plane/license.txt ${CURRENT_PACKAGES_DIR}/share/x-plane/copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/temp/)