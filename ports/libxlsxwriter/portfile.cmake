vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jmcnamara/libxlsxwriter
    REF RELEASE_0.9.4
    SHA512 d7bc319e6b9cd2ad6aaa2f3eb6fdce1c5bcc1d5af23ffb3413e29760191f6aed41f836aaa71a322efe7966f3753a6d8a01cb0b403d682b13a6a3734a87cc12ba
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
