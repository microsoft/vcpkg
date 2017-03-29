#cmake-only scripts
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/extra-cmake-modules-5.32.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://download.kde.org/stable/frameworks/5.32/extra-cmake-modules-5.32.0.zip"
    FILENAME "extra-cmake-modules-5.32.0.zip"
    SHA512 f966820e88fdbcdea7f20ff6b76ab8a6d2f7eaf78950bc690243b7201b9f646d92c83a998c19feab3bfe2ed528ec96ad1fa36e6ae320419d226cddd28cd433e5
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
