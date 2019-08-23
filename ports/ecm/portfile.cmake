#cmake-only scripts
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/extra-cmake-modules
    REF v5.60.0
    SHA512 98c7cbb0a84fbd4806cdf84538cb16717cbbb13fa5cce5c4bf9a507a699c579fa6f88af5091b3d311bdd504a119d6147114b2fad5de2dfd5f18448bca60cdc92
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
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
