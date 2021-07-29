vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/karchive
    REF v5.84.0
    SHA512 82926f62424446df0f4fc300f57ae9bd5baf8e13da2ce4135ac56c0c52a0307bffb06f84ac7e8e658e96ace2ae3d530f27e232061284ac87271404f218e9fdd4
    HEAD_REF master
    PATCHES
        5a79756f.patch # https://invent.kde.org/frameworks/karchive/-/commit/5a79756f381e1a1843cb2171bdc151dad53fb7db
        23.patch # https://invent.kde.org/frameworks/karchive/-/merge_requests/23
)

vcpkg_configure_cmake(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DBUILD_HTML_DOCS=OFF
        -DBUILD_MAN_DOCS=OFF
        -DBUILD_QTHELP_DOCS=OFF
    MAYBE_UNUSED_VARIABLES 
        BUILD_HTML_DOCS
        BUILD_MAN_DOCS
        BUILD_QTHELP_DOCS
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Archive)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSES/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
