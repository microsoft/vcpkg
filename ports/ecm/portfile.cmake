vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/extra-cmake-modules
    REF c427b4e94ebb5f6557823315cf518d77c634a08e # v5.66.0
    SHA512 b7eb19d28fe242ed6e5bf507525806796ea312d80f31c97028ef08b2593a285767ed2269ff990b6ddc5e22424bdccd963ab8be880f84c6c7395e7f29ad289110
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_HTML_DOCS=OFF
        -DBUILD_MAN_DOCS=OFF
        -DBUILD_QTHELP_DOCS=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

# Remove debug files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(COPY ${CURRENT_PORT_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/ecm)
# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING-CMAKE-SCRIPTS DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
