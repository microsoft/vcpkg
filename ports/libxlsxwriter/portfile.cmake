include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH 
    REPO jmcnamara/libxlsxwriter
    REF RELEASE_0.8.7
    SHA512 20bf09f084808a8db00315848213c550fb809b587ea49ce3b25b310de981c176a44c518452507b6e00ca3f0a8e0056d88a6f575c031d54aa68791575cb9ab285
	HEAD_REF master
	PATCHES
        0001-fix-build-error.patch
        0002-fix-uwp-build.patch
        0003-fix-include-file.patch
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
