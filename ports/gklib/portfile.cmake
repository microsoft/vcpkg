if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KarypisLab/GKlib
    REF 8bd6bad750b2b0d90800c632cf18e8ee93ad72d7
    SHA512 128cd9a48047b18b8013288162556f0b0f1d81845f5445f7cc62590ab28c06ee0a6c602cc999ce268ab27237eca3e8295df6432d377e45071946b98558872997
    PATCHES
        android.patch
        build-fixes.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHINSTALL_PATH=GKlib
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
