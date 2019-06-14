include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH 
    REPO jmcnamara/libxlsxwriter
    REF RELEASE_0.8.6
    SHA512 60822dc5f87531edc97cf774e234f25229a605d4430061c24b95c387318e6e05dde1b0f2f433cea14c6f84ee901c1dffe0d174bfd7e2a8459f59bcee900097db
	HEAD_REF master
	PATCHES
        0001-fix-build-error.patch
        0002-fix-uwp-build.patch
)

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
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

file(COPY ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/License.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)