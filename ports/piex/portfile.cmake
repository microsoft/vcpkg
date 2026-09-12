vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(FIX_UPSTREAM_PR3
    URLS https://github.com/google/piex/commit/4d59203c0aa957e9b80a7c7ca78f7af1771dc033.patch?full_index=1
    SHA512 54eb8876204360be72e95d422ab147fd44cbb70749ccae8dd6167819b8f39ed522bc12b8273505a7da1c3a9c0eb85fd2ed98a10517f29ba9fc63de79aff62b53
    FILENAME piex-pr-3.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/piex
    REF "v${VERSION}"
    SHA512 4ab72ccce553e72b9a9b5bb164edb260e52caa527a8aa7b601906d7366a3c4b827845dd15fb319f130d677d417f20f1836b2faed56021b3a2be79e599abd6683
    HEAD_REF master
    PATCHES
        "${FIX_UPSTREAM_PR3}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
)
