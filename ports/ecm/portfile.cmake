#cmake-only scripts
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/extra-cmake-modules-5.37.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://download.kde.org/stable/frameworks/5.37/extra-cmake-modules-5.37.0.zip"
    FILENAME "extra-cmake-modules-5.37.0.zip"
    SHA512 a9cd585fb5c63452fc45c955df62b6e7aca3d19e47ca2db33216f83951645f393271f37a04630e5c7f01899063562548c2b0dfe79d7afa8661bb0a8bca5ccfbf
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

# Remove debug files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING-CMAKE-SCRIPTS DESTINATION ${CURRENT_PACKAGES_DIR}/share/ecm)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ecm/COPYING-CMAKE-SCRIPTS ${CURRENT_PACKAGES_DIR}/share/ecm/copyright)

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
