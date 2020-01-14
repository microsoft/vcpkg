vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jmcnamara/libxlsxwriter
    REF RELEASE_0.8.9
    SHA512 0442323b8e55000aa78a689820f8e446b5e925b5077c6ed163ad181b5a8f0e19fe71cc12c4781f47f70f0c702faa27e49655e813f7e90a855ab73dd2bd9f5d66
	HEAD_REF master
	PATCHES
        0001-fix-cmake-file.patch
)

if (VCPKG_TARGET_IS_UWP)
  set(USE_WINDOWSSTORE ON)
else()
  set(USE_WINDOWSSTORE OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
	OPTIONS -DWINDOWSSTORE=${USE_WINDOWSSTORE}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
