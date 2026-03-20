vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kitemmodels
    REF "v${VERSION}"
    SHA512 cf4f1530c348adbb26a3bbbdb9b2af793a824c07fe345beb1290c37ded57eafda388190420606256530f4bf5e3b91cdf18ac2cc7b2cbe20f8c005600fe90c3b0
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_QMLDIR=qml
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5ItemModels)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
