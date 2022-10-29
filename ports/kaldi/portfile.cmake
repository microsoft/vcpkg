vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kaldi-asr/kaldi
    REF ac29a6ff09823d1cbb4814da60360c966f33cd0d
    SHA512 0
    HEAD_REF master
    PATCHES
        fix-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMATHLIB=MKL
        -DKALDI_BUILD_EXE=OFF
        -DKALDI_BUILD_TEST=OFF
        -DKALDI_USE_PATCH_NUMBER=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kaldi CONFIG_PATH share/kaldi)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
