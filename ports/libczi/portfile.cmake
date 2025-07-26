set(LIBCZI_REPO_NAME ptahmose/libczi-zeiss)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    #REPO ZEISS/libczi
    REPO ${LIBCZI_REPO_NAME}
    REF a043cb8cd83e09072c303dd6c3ad3be629ff1ae4
    SHA512 9df9e91e79438b81715a9405b227def389ece9c484eb44941ba762c9c49b1fd482e286cc41b9f8a4c11e9c8d4d09c76ad25c672c70aae0da4dc5358f06276cb9
#    HEAD_REF jbl/vcpkg-test  # In order to the latest version of a branch, one must run "vcpkg install libczi --head".
                            # vcpkg aims at "reproducible builds", so it wants to use a specific commit - and must be told to use the latest commit of a branch with this "--head" option.
)

# # libCZI tries to use 'git' in its CMake build system (in order to find the version of the source code).
# # We inform vcpkg about this, so that it can find 'git' and pass it to the CMake build system of libCZI.

# # ask vcpkg to find git
# vcpkg_find_acquire_program(GIT)
# # Pass git to the port's cmake build system
# get_filename_component(GIT_EXE_PATH ${GIT} DIRECTORY)
# vcpkg_add_to_path(${GIT_EXE_PATH})

# Graceful fallback: define repo hash and branch
if (NOT DEFINED VCPKG_HEAD_VERSION)
    set(LIBCZI_REPO_HASH ${VCPKG_SOURCE_VERSION})
else()
    set(LIBCZI_REPO_HASH ${VCPKG_HEAD_VERSION})
endif()

if (NOT DEFINED VCPKG_HEAD_REF)
    set(LIBCZI_REPO_BRANCH "unknown")
else()
    set(LIBCZI_REPO_BRANCH ${VCPKG_HEAD_REF})
endif()

set(LIBCZI_REPO_URL "https://github.com/${LIBCZI_REPO_NAME}.git")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    ${FEATURE_OPTIONS}
    -DLIBCZI_DO_NOT_SET_MSVC_RUNTIME_LIBRARY=ON
    -DLIBCZI_BUILD_PREFER_EXTERNALPACKAGE_EIGEN3=ON
    -DLIBCZI_BUILD_PREFER_EXTERNALPACKAGE_ZSTD=ON
    -DLIBCZI_BUILD_UNITTESTS=OFF
    -DLIBCZI_ENABLE_INSTALL=ON
    -DLIBCZI_BUILD_DYNLIB=OFF
    -DLIBCZI_BUILD_CZICMD=OFF
    -DLIBCZI_REPOSITORY_HASH=${LIBCZI_REPO_HASH}   
    -DLIBCZI_REPOSITORY_BRANCH=${LIBCZI_REPO_BRANCH}
    -DLIBCZI_REPOSITORY_REMOTE=${LIBCZI_REPO_URL}
)

vcpkg_cmake_install()

# -----------------------------------------------------------------------------
# Fix casing issue: upstream installs CMake config files to share/libCZI/
# but vcpkg expects these to live in share/libczi/ (port name in lowercase)
#
# This mismatch causes vcpkg_cmake_config_fixup() to fail with:
#   ... does not exist: share/libczi
#
# Solution:
#   - Rename the directory share/libCZI → share/libczi
#   - This works safely on all platforms (Windows, Linux, macOS)
#   - Use 'file(RENAME ...)' to move the directory
#   - Guard with EXISTS to avoid errors on incremental builds
# -----------------------------------------------------------------------------

#set(_upper_cmake_dir "${CURRENT_PACKAGES_DIR}/share/libCZI")
#set(_lower_cmake_dir "${CURRENT_PACKAGES_DIR}/share/libczi")

#if(EXISTS "${_upper_cmake_dir}")
#    file(RENAME "${_upper_cmake_dir}" "${_lower_cmake_dir}")
#endif()

# Tell vcpkg_cmake_config_fixup where to find the config files
# We must disable automatic path inference (because of the rename above)
#set(VCPKG_CMAKE_CONFIG_FIXUP_NO_CONFIG_DIR ON)

# Now fix up the CMake config path, pointing to the renamed directory
set(VCPKG_CMAKE_CONFIG_FIXUP_NO_CONFIG_DIR ON)
vcpkg_cmake_config_fixup(CONFIG_PATH share/libczi)


# Rename CMake config files to lowercase for CMake compatibility
file(RENAME "${CURRENT_PACKAGES_DIR}/share/libczi/libCZIConfig.cmake"          "${CURRENT_PACKAGES_DIR}/share/libczi/libcziConfig.cmake")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/libczi/libCZIConfigVersion.cmake"   "${CURRENT_PACKAGES_DIR}/share/libczi/libcziConfigVersion.cmake")


# vcpkg_cmake_config_fixup(CONFIG_PATH share/${PORT})

# vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
# vcpkg_fixup_pkgconfig()
