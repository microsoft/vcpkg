vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/knewstuff
    REF v5.88.0
    SHA512 7ed98ec253a35b10694964ecdbfd77afa640032536d189eeef52a5e32fb0b591baeced6d163f469183dd1515f9ebd26bc60952066d4a884834e572682f5ff393
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_QMLDIR=qml
        -DBUNDLE_INSTALL_DIR=bin
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5NewStuff CONFIG_PATH lib/cmake/KF5NewStuff DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5NewStuffCore CONFIG_PATH lib/cmake/KF5NewStuffCore DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5NewStuffQuick CONFIG_PATH lib/cmake/KF5NewStuffQuick)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES knewstuff-dialog
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

