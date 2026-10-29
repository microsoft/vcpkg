vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GillesDebunne/libQGLViewer
    REF "v${VERSION}"
    SHA512 09bfc5c0f07e51625a9af0094b83f40f84ead55a67c6e492c9702521f58c6b461bc840382fb73b64d16ad71a0a2a75d04aa12a77a78ced0a19e0e784e8d36bd7
    PATCHES
        Add-compile-definitions.patch
        Fix-error-c2039.patch #https://github.com/GillesDebunne/libQGLViewer/pull/80
        glu.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENCE")
