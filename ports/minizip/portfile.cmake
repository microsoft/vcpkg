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
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bzip2   ENABLE_BZIP2
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/minizipConfig.cmake.in" "${SOURCE_PATH}/cmake/minizipConfig.cmake.in" COPYONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" "${SOURCE_PATH}/CMakeLists.txt" COPYONLY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DDISABLE_INSTALL_TOOLS=${VCPKG_TARGET_IS_IOS}
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/minizip")

if ("bzip2" IN_LIST FEATURES)
    file(GLOB HEADERS "${CURRENT_PACKAGES_DIR}/include/minizip/*.h")
    foreach(HEADER ${HEADERS})
        file(READ "${HEADER}" _contents)
        string(REPLACE "#ifdef HAVE_BZIP2" "#if 1" _contents "${_contents}")
        file(WRITE "${HEADER}" "${_contents}")
    endforeach()
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/contrib/minizip/MiniZip64_info.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
