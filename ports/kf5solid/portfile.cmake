include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/solid
    REF v5.51.0
    SHA512 8b09ec9ac47d146c1c240e370a5bcda923e811493221b0ce7887387fc0a583d12771138c923a30f4f4a14c35c1e24d045b524e943975ed838d815a0d189e5364
    HEAD_REF master
)

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_EXE_PATH ${FLEX} DIRECTORY)
vcpkg_add_to_path(${FLEX_EXE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
            -DKDE_INSTALL_QMLDIR=qml
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Solid)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/solid-hardware5.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/solid-hardware5.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/kf5solid RENAME copyright)
