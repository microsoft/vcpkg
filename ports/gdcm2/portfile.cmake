include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO malaterre/GDCM
    REF v2.8.9
    SHA512 3c80503de6df8fe2589849ae9334d11e3cb033701450e1d7ea2781d122d1c8c1fc205fefc358d0ad1b9c5199c838e1c7c1bb34949da1c73cc8ae174b72e7e70c
    HEAD_REF master
    PATCHES find-openjpeg.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(GDCM_BUILD_SHARED_LIBS ON)
else()
    set(GDCM_BUILD_SHARED_LIBS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DGDCM_BUILD_DOCBOOK_MANPAGES=OFF
        -DGDCM_BUILD_SHARED_LIBS=${GDCM_BUILD_SHARED_LIBS}
        -DGDCM_INSTALL_INCLUDE_DIR=include
        -DGDCM_USE_SYSTEM_EXPAT=ON
        -DGDCM_USE_SYSTEM_ZLIB=ON
        -DGDCM_USE_SYSTEM_OPENJPEG=ON
        -DGDCM_BUILD_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/gdcm-2.8 TARGET_PATH share/gdcm)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/gdcm2 RENAME copyright)

vcpkg_copy_pdbs()
