vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jmcnamara/libxlsxwriter
    REF RELEASE_0.9.5
    SHA512 380006a0a5c459a74fd161954ac7f833f12503d95257758d5040417fddbce7804ecca8ddb18eaf2a8578f0ba472a7d81c2373440f2c39dd465da22ac47821466
	HEAD_REF master
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
