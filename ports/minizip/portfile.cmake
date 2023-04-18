# When this port is updated, the minizip port should be updated at the same time

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO madler/zlib
    REF v1.2.13
    SHA512 44b834fbfb50cca229209b8dbe1f96b258f19a49f5df23b80970b716371d856a4adf525edb4c6e0e645b180ea949cb90f5365a1d896160f297f56794dd888659
    HEAD_REF master
    PATCHES
        0001-remove-ifndef-NOUNCRYPT.patch
        0002-add-declaration-for-mkdir.patch
        0003-no-io64.patch
        pkgconfig.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bzip2   ENABLE_BZIP2
    INVERTED_FEATURES
        tools   DISABLE_INSTALL_TOOLS
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
          "${CMAKE_CURRENT_LIST_DIR}/unofficial-minizipConfig.cmake.in"
    DESTINATION "${SOURCE_PATH}/contrib/minizip"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/contrib/minizip"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPACKAGE_VERSION=${VERSION}
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
        -DDISABLE_INSTALL_TOOLS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-minizip)
vcpkg_fixup_pkgconfig()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES minizip miniunz AUTO_CLEAN)
endif()

if ("bzip2" IN_LIST FEATURES)
    file(GLOB HEADERS "${CURRENT_PACKAGES_DIR}/include/minizip/*.h")
    foreach(HEADER ${HEADERS})
        vcpkg_replace_string("${HEADER}" "#ifdef HAVE_BZIP2" "#if 1")
    endforeach()
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/minizipConfig.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/minizipConfig.cmake" @ONLY)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/contrib/minizip/MiniZip64_info.txt")
