include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO malaterre/GDCM
    REF v3.0.3
    SHA512 d1b95ec342341f026f03ead569c20d4482611b6ba1616fab2aaeec617675c678db7e7d9d14820364231b1319ece284f0cd3c35f356b20ef22f7e8ccf8a3fbc21
    HEAD_REF master
    PATCHES
        use-openjpeg-config.patch
        fix-share-path.patch
		Fix-Cmake_DIR.patch
)

file(REMOVE ${SOURCE_PATH}/CMake/FindOpenJPEG.cmake)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(VCPKG_BUILD_SHARED_LIBS ON)
else()
  set(VCPKG_BUILD_SHARED_LIBS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGDCM_BUILD_DOCBOOK_MANPAGES=OFF
        -DGDCM_BUILD_SHARED_LIBS=${VCPKG_BUILD_SHARED_LIBS}
        -DGDCM_INSTALL_INCLUDE_DIR=include
        -DGDCM_USE_SYSTEM_EXPAT=ON
        -DGDCM_USE_SYSTEM_ZLIB=ON
        -DGDCM_USE_SYSTEM_OPENJPEG=ON
        -DGDCM_BUILD_TESTING=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/gdcm)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

file(READ ${CURRENT_PACKAGES_DIR}/share/gdcm/GDCMTargets.cmake GDCM_TARGETS)
string(REPLACE "set(CMAKE_IMPORT_FILE_VERSION 1)"
               "set(CMAKE_IMPORT_FILE_VERSION 1)
find_package(OpenJPEG QUIET)" GDCM_TARGETS "${GDCM_TARGETS}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/gdcm/GDCMTargets.cmake "${GDCM_TARGETS}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(INSTALL ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/gdcm RENAME copyright)
