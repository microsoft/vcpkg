include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taglib/taglib
    REF 662f340f933077a926de443c9882f483973570e3
    SHA512 34087f77bb099f1f8ec82926a212a562bf589fc13f54eac50a56730c4411af2f4dbf1b7d09877087899048c3070325aea02297c6a94d0ad43fbf6742363dd2b6
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