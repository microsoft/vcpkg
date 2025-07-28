# -------------------------------
# Package metadata and source
# -------------------------------

set(LIBCZI_REPO_NAME ZEISS/libczi)
set(LIBCZI_REPO_REF cc041191e64f59b4d3abba90ced4203c783c53e2)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ${LIBCZI_REPO_NAME}
    REF ${LIBCZI_REPO_REF}
    SHA512 9df2767149c088160fec4b33e413bf3d69cac44b15d52d2f902be1fc908e75a8fd81886b7fa67bbef039b936b6743490aac731cdd9b812d7bdeaff3aa4fe99b6
)

# --- Allow installation of headers in debug/include (not typical, but harmless here)
# vcpkg normally expects all headers to be installed under 'include/', not 'debug/include/'.
# However, some upstream build systems (like libCZI's) install headers in both configurations by default.
# This policy suppresses a warning about that, assuming the headers are identical in both debug and release.
set(VCPKG_POLICY_ALLOW_DEBUG_INCLUDE enabled)

# -------------------------------
# VCS metadata injection
# These values are passed to CMake for embedding version info
# -------------------------------

set(LIBCZI_REPO_HASH ${LIBCZI_REPO_REF})
set(LIBCZI_REPO_BRANCH "unknown")
set(LIBCZI_REPO_URL "https://github.com/${LIBCZI_REPO_NAME}.git")

# -------------------------------
# Configure CMake
# -------------------------------

# c.f. https://learn.microsoft.com/en-us/vcpkg/contributing/maintainer-guide#only-static-or-shared
# We use the BUILD_SHARED_LIBCZI option to determine whether to build a shared or static library.
# libCZI will always build a static library, but we can choose to build a shared library if LIBCZI_BUILD_DYNLIB is set to ON.
# libCZI will install the static library if LIBCZI_BUILD_DYNLIB is OFF, and the dynamic library if it is ON.
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBCZI)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    ${FEATURE_OPTIONS}
    -DCRASH_ON_UNALIGNED_ACCESS=FALSE # for cross-compilation scenarios, we want to prevent execution of 
    -DIS_BIG_ENDIAN=FALSE             # test-programs inside the libCZI-build-scripts
    -DLIBCZI_DO_NOT_SET_MSVC_RUNTIME_LIBRARY=ON # Do not set the MSVC runtime library, use it as it is set by vcpkg.
    -DLIBCZI_BUILD_PREFER_EXTERNALPACKAGE_EIGEN3=ON
    -DLIBCZI_BUILD_PREFER_EXTERNALPACKAGE_ZSTD=ON
    -DLIBCZI_BUILD_UNITTESTS=OFF                # Do not build unit tests.
    -DLIBCZI_ENABLE_INSTALL=ON
    -DLIBCZI_BUILD_DYNLIB=${BUILD_SHARED_LIBCZI}
    -DLIBCZI_BUILD_CZICMD=OFF                   # Do not build the command line tool
    -DLIBCZI_REPOSITORY_HASH=${LIBCZI_REPO_HASH}   
    -DLIBCZI_REPOSITORY_BRANCH=${LIBCZI_REPO_BRANCH}
    -DLIBCZI_REPOSITORY_REMOTE=${LIBCZI_REPO_URL}
)

# -------------------------------
# Install step
# -------------------------------

vcpkg_cmake_install()

# -------------------------------
# Fixup step for proper integration
#
# Set CONFIG_PATH to actual install location of config files
# and prevent redundant search-path rewriting
# -------------------------------

set(VCPKG_CMAKE_CONFIG_FIXUP_NO_CONFIG_DIR ON)
vcpkg_cmake_config_fixup(CONFIG_PATH share/libczi)

# --- Install license file to correct location ---
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
