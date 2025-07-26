# -------------------------------
# Package metadata and source
# -------------------------------

set(LIBCZI_REPO_NAME ptahmose/libczi-zeiss)
set(LIBCZI_REPO_REF a043cb8cd83e09072c303dd6c3ad3be629ff1ae4)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ${LIBCZI_REPO_NAME}
    REF ${LIBCZI_REPO_REF}
    SHA512 9df9e91e79438b81715a9405b227def389ece9c484eb44941ba762c9c49b1fd482e286cc41b9f8a4c11e9c8d4d09c76ad25c672c70aae0da4dc5358f06276cb9
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    ${FEATURE_OPTIONS}
    -DLIBCZI_DO_NOT_SET_MSVC_RUNTIME_LIBRARY=ON # Do not set the MSVC runtime library, use it as it is set by vcpkg.
    -DLIBCZI_BUILD_PREFER_EXTERNALPACKAGE_EIGEN3=ON
    -DLIBCZI_BUILD_PREFER_EXTERNALPACKAGE_ZSTD=ON
    -DLIBCZI_BUILD_UNITTESTS=OFF    # Do not build unit tests.
    -DLIBCZI_ENABLE_INSTALL=ON
    -DLIBCZI_BUILD_DYNLIB=OFF       # Only build static lib by default, dynamic lib is chosen by vcpkg with the BUILD_SHARED_LIBS option.
    -DLIBCZI_BUILD_CZICMD=OFF       # Do not build the command line tool
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
