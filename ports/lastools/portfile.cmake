if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} doesn't currently support UWP.")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LAStools/LAStools
    REF v2.0.2
    SHA512 39d387b572b582471b788e94b51c46130ae44bc64835606e0a35dfc4ea7765be96a88c05f7e176b0f08474041737d02530cdc5f3379dda4e24aba08d43c98d37
    HEAD_REF master
    PATCHES 
        "fix_install_paths_lastools.patch"
        "fix_include_directories_lastools.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_cmake_config_fixup(PACKAGE_NAME LASlib CONFIG_PATH "share/lastools/LASlib")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
     file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

