include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO saprykin/plibsys
    REF 0.0.4
    SHA512 61957666fb454469e1ff68435463eaf426e960caed33540dbb495e1aa7c446c9803d100f33f1a6ea70d5f2ee2d0d19ec315f3a8c651747f65a186ad061c05e51
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    SET(PLIBSYS_STATIC OFF)
else()
    SET(PLIBSYS_STATIC ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPLIBSYS_TESTS=OFF
        -DPLIBSYS_COVERAGE=OFF
        -DPLIBSYS_BUILD_STATIC=${PLIBSYS_STATIC}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/plibsys RENAME copyright)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(PLIBSYS_FILENAME plibsys)

    # Put shared libraries into the proper directory
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)

    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/plibsys.dll ${CURRENT_PACKAGES_DIR}/bin/plibsys.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/plibsys.dll ${CURRENT_PACKAGES_DIR}/debug/bin/plibsys.dll)
else()
    set(PLIBSYS_FILENAME plibsysstatic)

    # For static build remove dynamic libraries
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/plibsys.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/plibsys.dll)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/plibsys.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/plibsys.dll)
endif()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tmp)

# Save library files
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/${PLIBSYS_FILENAME}.lib ${CURRENT_PACKAGES_DIR}/tmp/plibsys.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/${PLIBSYS_FILENAME}.lib ${CURRENT_PACKAGES_DIR}/tmp/plibsys_debug.lib)

# Remove unused shared libraries
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib)

# Re-install library files
file(RENAME ${CURRENT_PACKAGES_DIR}/tmp/plibsys.lib ${CURRENT_PACKAGES_DIR}/lib/plibsys.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/tmp/plibsys_debug.lib ${CURRENT_PACKAGES_DIR}/debug/lib/plibsys.lib)

# Remove duplicate library files (already installed)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tmp)

vcpkg_copy_pdbs()
