vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ABRG-Models/morphologica
    REF v${VERSION}
    SHA512 6f26b9fb19587308613c7ba5b89ce894025a271edda4f1262daf2fff68336cbc9d14e744aced18d78282178a04bc2076ad893d800ed20105045f8f236272ebe9
    PATCHES
        remove_number_type.patch
        egl_fix.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

