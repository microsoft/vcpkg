vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO glassechidna/zxing-cpp
    REF 5aad4744a3763d814df98a18886979893e638274
    SHA512 a079ad47171224de4469e76bf0779b6ebc9c6dfb3604bd5dbf5e6e5f321d9e6255f689daa749855f8400023602f1773214013c006442e9b32dd4b8146c888c02
    HEAD_REF master
    PATCHES
      0001-opencv4-compat.patch
      0002-improve-features.patch
)

file(REMOVE ${SOURCE_PATH}/cmake/FindModules/FindIconv.cmake)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    opencv WITH_OPENCV
    iconv WITH_ICONV
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS  ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/zxing/cmake TARGET_PATH share/zxing)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT})
if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/zxing.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
else()
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/zxing DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/zxing)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/zxing)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
