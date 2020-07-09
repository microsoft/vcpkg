vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO geographiclib
    REF distrib
    FILENAME "GeographicLib-1.50.1.tar.gz"
    SHA512 1db874f30957a0edb8a1df3eee6db73cc993629e3005fe912e317a4ba908e7d7580ce483bb0054c4b46370b8edaec989609fb7e4eb6ba00c80182db43db436f1
    PATCHES
        remove-tools-and-fix-version.patch
        fix-usage.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(GEOGRAPHICLIB_LIB_TYPE SHARED)
else()
    set(GEOGRAPHICLIB_LIB_TYPE STATIC)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS 
        -DGEOGRAPHICLIB_LIB_TYPE=${GEOGRAPHICLIB_LIB_TYPE}
)

vcpkg_install_cmake()

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/GeographicLib)
endif()
vcpkg_copy_pdbs()

file(COPY ${CURRENT_PACKAGES_DIR}/lib/pkgconfig DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)