#cmake-only scripts
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/extra-cmake-modules
    REF v5.56.0
    SHA512 6a65eeaae1974e4bb3b8910875d29cf48ee4d83627aa38179213110aa7e5a058e1721de53eb629baa8e27fd0853a8bbd5aaa2dc001ae4651626d9b7a83c79fa5
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
