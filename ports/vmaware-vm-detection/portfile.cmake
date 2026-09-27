vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kernelwernel/VMAware
    REF v${VERSION}
    SHA512 bf845ed1c44c4d20fc7cd0a009b79d6591f63697d126fb6d9ab00dc071109fd6066e48d7124aeb9692555d016114f2a40acb6b8f48440e7839ece751ab9712bb
    HEAD_REF master
    PATCHES
        001-fix-linkage.patch
)

# Header only
set(VCPKG_BUILD_TYPE release)
file(INSTALL "${SOURCE_PATH}/src/vmaware.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/vmaware")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
