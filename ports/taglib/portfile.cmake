vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taglib/taglib
    REF c8b39449c383158b4d669ee97374543f9d0733bf #v1.12
    SHA512 b64a4b8c79f411dd2dbbf804fb4720289d568ea749ad90ba7f12a5a64f123a060819dc48d80bd58fb1b1433f52db7fb22bfa5d212b6fb79e2c006f0791441d91
    HEAD_REF master
)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
	set(WINRT_OPTIONS -DHAVE_VSNPRINTF=1 -DPLATFORM_WINRT=1)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${WINRT_OPTIONS}
)

vcpkg_install_cmake()

# remove the debug/include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# copyright file
file(COPY ${SOURCE_PATH}/COPYING.LGPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/taglib)
file(COPY ${SOURCE_PATH}/COPYING.MPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/taglib)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/taglib/COPYING.LGPL ${CURRENT_PACKAGES_DIR}/share/taglib/copyright)

# remove bin directory for static builds (taglib creates a cmake batch file there)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_pdbs()