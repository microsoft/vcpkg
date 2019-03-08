include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/texus/TGUI/archive/v0.8.4.tar.gz"
    FILENAME "tgui-0.8.4.zip"
    SHA512 52d38419a1650cbde517a5022e3b719b9fb4c3b336533c35aa839757f929b56e477d397d735170ba8be434afedc4c00bfcd4898d97da66015776b5f22bb04ea0
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

# Enable static build
file(REMOVE ${SOURCE_PATH}/cmake/Modules/FindSFML.cmake)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" TGUI_SHARED_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DTGUI_BUILD_GUI_BUILDER=OFF
        -DTGUI_MISC_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/share/tgui
        -DTGUI_SHARED_LIBS=${TGUI_SHARED_LIBS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/TGUI)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tgui/license.txt ${CURRENT_PACKAGES_DIR}/share/tgui/copyright)
