set(LIBCZI_REPO_NAME ptahmose/libczi-zeiss)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    #REPO ZEISS/libczi
    REPO ${LIBCZI_REPO_NAME}
    REF aba67dd5044f950efdfa1e2a155b6d3cc4c85c6b
    SHA512 2500918d5d994119e9ae03d47a65533707f87d853dc458a067b55b5b8f306ddc9c3ddd0dd656ab86c1316f168c8eba1235c545619f7579cce8b6a5e5e57c9d49
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
    -DLIBCZI_REPOSITORY_HASH=${LIBCZI_REPO_HASH}   
    -DLIBCZI_REPOSITORY_BRANCH=${LIBCZI_REPO_BRANCH}
    -DLIBCZI_REPOSITORY_REMOTE=${LIBCZI_REPO_URL}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
# vcpkg_cmake_config_fixup(CONFIG_PATH share/${PORT})

# vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
# vcpkg_fixup_pkgconfig()
