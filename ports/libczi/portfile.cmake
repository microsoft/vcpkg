set(LIBCZI_REPO_NAME ZEISS/libczi)
set(LIBCZI_REPO_REF 00eeab5f1c99c4595862db60da15c42089677ec4)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ${LIBCZI_REPO_NAME}
    REF ${LIBCZI_REPO_REF}
    SHA512 24b376a0f8ad50113f53704ec7e4e44eeea8d88acd5c15dc7bd050045cdd8fd48b125680d7dafaeb768e86af4857db01614d6479ec91c6327ef2f70da9aa5350
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBCZI)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBCZI_DO_NOT_SET_MSVC_RUNTIME_LIBRARY=ON  # set by vcpkg
        -DLIBCZI_BUILD_CZICMD=OFF  # could be feature
        -DLIBCZI_BUILD_DYNLIB=${BUILD_SHARED_LIBCZI}
        -DLIBCZI_BUILD_PREFER_EXTERNALPACKAGE_EIGEN3=ON
        -DLIBCZI_BUILD_PREFER_EXTERNALPACKAGE_ZSTD=ON
        -DLIBCZI_BUILD_UNITTESTS=OFF
        -DLIBCZI_ENABLE_INSTALL=ON
        # for cross-compilation scenarios, prevent execution of test-programs inside the libCZI-build-scripts
        -DCRASH_ON_UNALIGNED_ACCESS=FALSE
        -DIS_BIG_ENDIAN=FALSE
        # VCS metadata injection
        -DLIBCZI_REPOSITORY_HASH=${LIBCZI_REPO_REF}   
        -DLIBCZI_REPOSITORY_BRANCH=unknown
        -DLIBCZI_REPOSITORY_REMOTE=https://github.com/${LIBCZI_REPO_NAME}.git
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/libczi)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
