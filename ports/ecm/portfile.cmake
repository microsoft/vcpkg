#cmake-only scripts
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/extra-cmake-modules
    REF 0c95c9f799cd5cfc5b36ae34ea7fceda13d14c0e
    SHA512 5e30297d86952d49a6e95e0dcbb3c08543521f1cc129aa66d03370c383e8ceb95d211cdbe6c8062ba59b632ed54f030be5e7bace5c6a8ccf34071977ec0ade8a
    HEAD_REF master
)

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
