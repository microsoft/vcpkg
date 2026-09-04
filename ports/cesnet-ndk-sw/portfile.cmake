vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CESNET/ndk-sw
    REF "v${VERSION}"
    SHA512 d2cba5d8ee77cecb6874e964ee63086a8ac45530654d444ed49281e774b36a27364067076a836caf04e93371678db8ba0b3849700a1176b0256ad9b8490b06a7
    HEAD_REF main
    PATCHES
        0001-disable-cpack.patch
        0002-disable-drivers.patch
        0003-disable-optional-deps.patch
        0004-disable-tools.patch
        0005-fix-pkgconfig-version.patch
        0006-nfb-static-or-shared.patch
        0007-fpga-image-load.patch
        0008-fix-install-location.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DVERSION=${VERSION}"
        "-DVERSION_MAJOR=${VERSION_MAJOR}"
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/etc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
