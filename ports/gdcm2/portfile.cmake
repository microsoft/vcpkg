include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO malaterre/GDCM
    REF v2.8.8
    SHA512 92efa1b85e38a5e463933c36a275e1392608c9da4d7c3ab17acfa70bfa112bc03e8705086eaac4a3ad5153fde5116ccc038093adaa8598b18000f403f39db738
    PATCHES socketxx.patch
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
        ${ADDITIONAL_OPTIONS}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/gdcm2 RENAME copyright)

vcpkg_copy_pdbs()
