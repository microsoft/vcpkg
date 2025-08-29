set(LIBCZI_REPO_NAME ZEISS/libczi)
set(LIBCZI_REPO_REF cc79cffe2ff144c3b889102c30c7d1094d757993)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ${LIBCZI_REPO_NAME}
    REF ${LIBCZI_REPO_REF}
    SHA512 e0c08c8e8f1abbfd029d7d47439960bc25f19f718a6fa732ba360a5e5cebdb6d0619f335e083686ef6e51e9a77316ecc447ec52cdbc3c57b64d6c2964c9d3c01
)

# Translate enabled vcpkg features into CMake -D flags:
vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTS
    FEATURES
        azureblobstore  LIBCZI_BUILD_AZURESDK_BASED_STREAM
        curl            LIBCZI_BUILD_CURL_BASED_STREAM 
        curl            LIBCZI_BUILD_PREFER_EXTERNALPACKAGE_LIBCURL
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBCZI)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTS}
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
        -DNEON_INTRINSICS_CAN_BE_USED=TRUE        
        # VCS metadata injection
        -DLIBCZI_REPOSITORY_HASH=${LIBCZI_REPO_REF}   
        -DLIBCZI_REPOSITORY_BRANCH=unknown
        -DLIBCZI_REPOSITORY_REMOTE=https://github.com/${LIBCZI_REPO_NAME}.git
    MAYBE_UNUSED_VARIABLES        
        CRASH_ON_UNALIGNED_ACCESS
        IS_BIG_ENDIAN
        NEON_INTRINSICS_CAN_BE_USED
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/libczi)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
