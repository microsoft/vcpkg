vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/extra-cmake-modules
    REF v5.81.0
    SHA512 562e99f3368ec5c834dbcbfb055c06da3e3302ac8e03d5d71be9f2fc682bbb02836c009c41777a7f90e4d6d3a4b13412aea29fdba985588b7d59e2dc59c9beb2
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

file(COPY ${CURRENT_PORT_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING-CMAKE-SCRIPTS DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
