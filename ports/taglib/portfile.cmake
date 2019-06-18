include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taglib/taglib
    REF ba7adc2bc261ed634c2a964185bcffb9365ad2f4
    SHA512 faf516f40f12031a37414ce9246ec409e64e570faebe2d604afdefbb7d665e0a0c9c68bec0e6dcb1c5ceb8fa8e1c3477f5ac75029f17beedd679fa3ea735ce6d
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