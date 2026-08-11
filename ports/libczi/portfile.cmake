set(LIBCZI_REPO_NAME ZEISS/libczi)
set(LIBCZI_REPO_REF 61f74ff097d6d0fbe6e36f204ff59d92e299d7cd)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ${LIBCZI_REPO_NAME}
    REF ${LIBCZI_REPO_REF}
    SHA512 5f1f487df249b4939e2c2fff3ec9a87771ec07f5da1bc8b0a9c487e67d75fd0384f0c7dbb753dba23c66296e5caf048fa334515d9fd63ca13e7bb7c936601f5b
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
        -DLIBCZI_BUILD_ENABLE_EXPERIMENTAL_FUNCTIONALITY=OFF
        -DLIBCZI_BUILD_EXPERIMENTAL_CHUNKED_COMPRESSION=OFF
        -DLIBCZI_BUILD_PREFER_EXTERNALPACKAGE_LZ4=ON
        -DLIBCZI_BUILD_PREFER_EXTERNALPACKAGE_EIGEN3=ON
        -DLIBCZI_BUILD_PREFER_EXTERNALPACKAGE_ZSTD=ON
        -DLIBCZI_BUILD_UNITTESTS=OFF
        -DLIBCZI_ENABLE_INSTALL=ON
        # for cross-compilation scenarios, prevent execution of test-programs inside the libCZI-build-scripts
        -DCRASH_ON_UNALIGNED_ACCESS=FALSE
        -DNEON_INTRINSICS_CAN_BE_USED=TRUE
        # Intentionally empty: Must be defined to avoid try-run.
        # Override in triplet if needed.
        -DADDITIONAL_LIBS_REQUIRED_FOR_ATOMIC:STRING=
        # VCS metadata injection
        -DLIBCZI_REPOSITORY_HASH=${LIBCZI_REPO_REF}
        -DLIBCZI_REPOSITORY_BRANCH=unknown
        -DLIBCZI_REPOSITORY_REMOTE=https://github.com/${LIBCZI_REPO_NAME}.git
    MAYBE_UNUSED_VARIABLES
        # Only checked when AVX is unavailable, arm_neon.h exists, and the compiler is not MSVC:
        # https://github.com/ZEISS/libczi/blob/61f74ff097d6d0fbe6e36f204ff59d92e299d7cd/Src/libCZI/CMakeLists.txt#L242-L261
        NEON_INTRINSICS_CAN_BE_USED
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/libczi)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/THIRD_PARTY_LICENSES.txt"
)
