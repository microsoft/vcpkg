include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/kplotting-5.37.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://download.kde.org/stable/frameworks/5.37/kplotting-5.37.0.zip"
    FILENAME "kplotting-5.37.0.zip"
    SHA512 3a1b3f993123dea7141d280cd53ae1b5e49b859e9df39a188bac216758576106efd8b744e8f10f96fac158f980d79ae94d2b27f3d85a48fcd5673263ffce3c4e
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Plotting)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/KF5plotting RENAME copyright)
