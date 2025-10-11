set(LIBCZI_REPO_NAME ZEISS/libczi)
set(LIBCZI_REPO_REF 2d6e9ac7b320373b099d55c8ebe0ac0cf16bb0da)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ${LIBCZI_REPO_NAME}
    REF ${LIBCZI_REPO_REF}
    SHA512 58b841406fa1478499db6cbae935d1b31ebfe8ba8276e92224a08ee828f617f9f51300b128728bc96ff032889cc24be1b9e9ecc033fc663acd613e2c2c93ffa5
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
        # Intentionally empty: Must be defined to avoid try-run.
        # Override in triplet if needed.
        -DADDITIONAL_LIBS_REQUIRED_FOR_ATOMIC:STRING=
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
