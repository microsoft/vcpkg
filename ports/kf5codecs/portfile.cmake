include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kcodecs
    REF v5.51.0
    SHA512 8dd1590a488c21f5a0c929b8e9e0de52acefa700d6d9a8410eb86495d7fb12f3b2faa3fbb1a5536fe012aa66aade2913cdd9efa312ac34de25f23cd7256273b6
    HEAD_REF master
)

vcpkg_find_acquire_program(GPERF)
get_filename_component(GPERF_EXE_PATH ${GPERF} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${GPERF_EXE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Codecs)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/kf5codecs RENAME copyright)
