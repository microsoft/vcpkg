vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF nov2020
    SHA512 9d10a851f37deb428c16166cdecf38ffba28a4ab836f9753f071bccc570fcb22ce98271c6bbad9fa1380dddd1fa6602156a7aa1607d347139bda1860fc2210ce
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        xaudio2-9 BUILD_XAUDIO_WIN10
        xaudio2-8 BUILD_XAUDIO_WIN8
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
)

if(NOT VCPKG_TARGET_IS_UWP)
    vcpkg_build_cmake()
else()
    vcpkg_build_cmake(TARGET DirectXTK)
endif()

file(INSTALL ${SOURCE_PATH}/Inc/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/DirectXTK)

file(GLOB_RECURSE DEBUG_LIB ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin/CMake/*.lib)
file(GLOB_RECURSE RELEASE_LIB ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake/*.lib)
file(INSTALL ${DEBUG_LIB} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${RELEASE_LIB} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
if(NOT VCPKG_TARGET_IS_UWP)
  vcpkg_copy_tools(
        TOOL_NAMES XWBTool
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )
    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH MakeSpriteFont/MakeSpriteFont.csproj
        PLATFORM AnyCPU
    )
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
