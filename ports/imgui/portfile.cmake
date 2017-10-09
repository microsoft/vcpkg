include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/imgui-1.51)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ocornut/imgui/archive/v1.51.zip"
    FILENAME "imgui-1.51.zip"
    SHA512 a3c77887396991f8371c0cf5b42d781d758877cdb194a7c6ea8b34939f4b300f55f176d601dd0e167ea2a20bd8a47b958ad1bca16864a19c1cc9b2c7a889ab29
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DIMGUI_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/imgui)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/imgui/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/imgui/copyright)
