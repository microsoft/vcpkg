vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO madler/zlib
    REF v1.2.11
    SHA512 104c62ed1228b5f1199bc037081861576900eb0697a226cafa62a35c4c890b5cb46622e399f9aad82ee5dfb475bae26ae75e2bd6da3d261361b1c8b996970faf
    HEAD_REF master
    PATCHES
        0001-remove-ifndef-NOUNCRYPT.patch
        0002-add-declaration-for-mkdir.patch
        0003-no-io64.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    bzip2 ENABLE_BZIP2
)

configure_file(${CMAKE_CURRENT_LIST_DIR}/minizipConfig.cmake.in  ${SOURCE_PATH}/cmake/minizipConfig.cmake.in COPYONLY)
configure_file(${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt  ${SOURCE_PATH}/CMakeLists.txt COPYONLY)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DDISABLE_INSTALL_TOOLS=${VCPKG_TARGET_IS_IOS}
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/minizip)

if ("bzip2" IN_LIST FEATURES)
    file(GLOB HEADERS "${CURRENT_PACKAGES_DIR}/include/minizip/*.h")
    foreach(HEADER ${HEADERS})
        file(READ "${HEADER}" _contents)
        string(REPLACE "#ifdef HAVE_BZIP2" "#if 1" _contents "${_contents}")
        file(WRITE "${HEADER}" "${_contents}")
    endforeach()
endif()

file(INSTALL ${SOURCE_PATH}/contrib/minizip/MiniZip64_info.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
