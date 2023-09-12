vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dankamongmen/notcurses
    REF "v${VERSION}"
    SHA512 e867d2436f7c953b4b7feb1464b73709cb792256e82956c933c43981dad802c30526d53d28ebafd8e460a3309ae4895cac4e0d1f6f89e347ab9578546798d19b
    HEAD_REF master
    PATCHES
        dependency-fix.patch
        fix-pc-file.patch
        disable-shared.patch
)

set(multimedia "none")
if ("ffmpeg" IN_LIST FEATURES)
    set(multimedia "ffmpeg")
endif()

set(linkage "OFF")
if(${VCPKG_LIBRARY_LINKAGE} STREQUAL "static")
	set(linkage "ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DBUILD_TESTING=OFF
      -DBUILD_EXECUTABLES=OFF
      -DUSE_PANDOC=OFF
      -DUSE_POC=OFF
      -DUSE_MULTIMEDIA=${multimedia}
	  -DUSE_STATIC=${linkage}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "${PORT}/cmake"
	CONFIG_PATH lib/cmake/Notcurses DO_NOT_DELETE_PARENT_CONFIG_PATH
)
vcpkg_cmake_config_fixup(PACKAGE_NAME "${PORT}/cmake"
	CONFIG_PATH lib/cmake/Notcurses++ DO_NOT_DELETE_PARENT_CONFIG_PATH
)
vcpkg_cmake_config_fixup(PACKAGE_NAME "${PORT}/cmake" CONFIG_PATH lib/cmake/NotcursesCore)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
