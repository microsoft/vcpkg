
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGNS/CGNS
    REF 3420e23febf0eb38c1b05af3c157d614d8476557 # v3.4.0
    SHA512 3fec1c32f1514cd9bc327f12f3f9db6a229df05f514193bd9e913d06b8ae6465664410a3c77a30b0c29f3e999e5efcb1ebed3a8b80e14be92035940c10b1d6d7
    HEAD_REF develop
    PATCHES
        hdf5.patch
        linux_lfs.patch
        zlib_szip_mpi.patch
        defines.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
   FEATURES
     mpi     HDF5_NEEDS_MPI
     fortran CGNS_ENABLE_FORTRAN
     tests   CGNS_ENABLE_TESTS
     hdf5    CGNS_ENABLE_HDF5
     lfs     CGNS_ENABLE_LFS
     legacy  CGNS_ENABLE_LEGACY
)

if(VCPKG_TARGET_ARCHITECTURE MATCHES "64")
    list(APPEND CGNS_BUILD_OPTS "-DCGNS_ENABLE_64BIT=ON")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND CGNS_BUILD_OPTS "-DCGNS_BUILD_SHARED=ON;-DCGNS_USE_SHARED=ON")
else()
    list(APPEND CGNS_BUILD_OPTS "-DCGNS_BUILD_SHARED=OFF;-DCGNS_USE_SHARED=OFF")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS 
        ${FEATURE_OPTIONS}
        ${CGNS_BUILD_OPTS}
)

vcpkg_install_cmake()

file(INSTALL ${CURRENT_PACKAGES_DIR}/include/cgnsBuild.defs DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/cgnsBuild.defs ${CURRENT_PACKAGES_DIR}/include/cgnsconfig.h)

file(INSTALL ${CURRENT_PORT_DIR}/cgnsconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include) # we patched the config and the include is all that is needed

IF(EXISTS ${CURRENT_PACKAGES_DIR}/debug) 
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/include/cgnsBuild.defs ${CURRENT_PACKAGES_DIR}/debug/include/cgnsconfig.h)
    file(REMOVE
        ${CURRENT_PACKAGES_DIR}/debug/bin/cgnscheck${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/debug/bin/cgnscompress${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/debug/bin/cgnsconvert${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/debug/bin/cgnsdiff${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/debug/bin/cgnslist${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/debug/bin/cgnsnames${VCPKG_TARGET_EXECUTABLE_SUFFIX})
endif()
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/cgnsBuild.defs ${CURRENT_PACKAGES_DIR}/include/cgnsconfig.h)
file(GLOB_RECURSE BATCH_FILES ${CURRENT_PACKAGES_DIR}/bin/*.bat)
file(INSTALL
    ${BATCH_FILES}
    ${CURRENT_PACKAGES_DIR}/bin/cgnscheck${VCPKG_TARGET_EXECUTABLE_SUFFIX}
    ${CURRENT_PACKAGES_DIR}/bin/cgnscompress${VCPKG_TARGET_EXECUTABLE_SUFFIX}
    ${CURRENT_PACKAGES_DIR}/bin/cgnsconvert${VCPKG_TARGET_EXECUTABLE_SUFFIX}
    ${CURRENT_PACKAGES_DIR}/bin/cgnsdiff${VCPKG_TARGET_EXECUTABLE_SUFFIX}
    ${CURRENT_PACKAGES_DIR}/bin/cgnslist${VCPKG_TARGET_EXECUTABLE_SUFFIX}
    ${CURRENT_PACKAGES_DIR}/bin/cgnsnames${VCPKG_TARGET_EXECUTABLE_SUFFIX}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(REMOVE
    ${BATCH_FILES}
    ${CURRENT_PACKAGES_DIR}/bin/cgnscheck${VCPKG_TARGET_EXECUTABLE_SUFFIX}
    ${CURRENT_PACKAGES_DIR}/bin/cgnscompress${VCPKG_TARGET_EXECUTABLE_SUFFIX}
    ${CURRENT_PACKAGES_DIR}/bin/cgnsconvert${VCPKG_TARGET_EXECUTABLE_SUFFIX}
    ${CURRENT_PACKAGES_DIR}/bin/cgnsdiff${VCPKG_TARGET_EXECUTABLE_SUFFIX}
    ${CURRENT_PACKAGES_DIR}/bin/cgnslist${VCPKG_TARGET_EXECUTABLE_SUFFIX}
    ${CURRENT_PACKAGES_DIR}/bin/cgnsnames${VCPKG_TARGET_EXECUTABLE_SUFFIX}
    )
    
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# # Moves all .cmake files from /debug/share/cgns/ to /share/cgns/
# # See /docs/maintainers/vcpkg_fixup_cmake_targets.md for more details
# vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/cgns)

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# # Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME cgns)
