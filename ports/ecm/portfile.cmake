vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/extra-cmake-modules
    REF v5.87.0
    SHA512 024dd6631d975228d3a2b681266d84bf336bd3152b88d641761a18f5367e740f968240517040ec0d97135b69fd16f4de607e01e76c2c689f65d96ebd520feed5
    HEAD_REF master
    PATCHES
        fix_canberra.patch       # https://invent.kde.org/frameworks/extra-cmake-modules/-/merge_requests/187
        fix_libmount.patch       # https://invent.kde.org/frameworks/extra-cmake-modules/-/merge_requests/200
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_HTML_DOCS=OFF
        -DBUILD_MAN_DOCS=OFF
        -DBUILD_QTHELP_DOCS=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

# Remove debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING-CMAKE-SCRIPTS" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

