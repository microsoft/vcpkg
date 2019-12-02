# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   CURRENT_INSTALLED_DIR     = ${VCPKG_ROOT_DIR}\installed\${TRIPLET}
#   DOWNLOADS                 = ${VCPKG_ROOT_DIR}\downloads
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#   VCPKG_TOOLCHAIN           = ON OFF
#   TRIPLET_SYSTEM_ARCH       = arm x86 x64
#   BUILD_ARCH                = "Win32" "x64" "ARM"
#   MSBUILD_PLATFORM          = "Win32"/"x64"/${TRIPLET_SYSTEM_ARCH}
#   DEBUG_CONFIG              = "Debug Static" "Debug Dll"
#   RELEASE_CONFIG            = "Release Static"" "Release DLL"
#   VCPKG_TARGET_IS_WINDOWS
#   VCPKG_TARGET_IS_UWP
#   VCPKG_TARGET_IS_LINUX
#   VCPKG_TARGET_IS_OSX
#   VCPKG_TARGET_IS_FREEBSD
#   VCPKG_TARGET_IS_ANDROID
#   VCPKG_TARGET_EXECUTABLE_SUFFIX
#   VCPKG_TARGET_STATIC_LIBRARY_SUFFIX
#   VCPKG_TARGET_SHARED_LIBRARY_SUFFIX
#
# 	See additional helpful variables in /docs/maintainers/vcpkg_common_definitions.md 

# # Specifies if the port install should fail immediately given a condition
# vcpkg_fail_port_install(MESSAGE "cgns currently only supports Linux and Mac platforms" ON_TARGET "Windows")


vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGNS/CGNS
    REF 3420e23febf0eb38c1b05af3c157d614d8476557 # v3.4.0
    SHA512 3fec1c32f1514cd9bc327f12f3f9db6a229df05f514193bd9e913d06b8ae6465664410a3c77a30b0c29f3e999e5efcb1ebed3a8b80e14be92035940c10b1d6d7
    HEAD_REF develop
    PATCHES
        hdf5.patch
)

# # Check if one or more features are a part of a package installation.
# # See /docs/maintainers/vcpkg_check_features.md for more details
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
   FEATURES # <- Keyword FEATURES is required because INVERTED_FEATURES are being used
     mpi     HDF5_NEEDS_MPI
     fortran CGNS_ENABLE_FORTRAN
     tests   CGNS_ENABLE_TESTS
     hdf5    CGNS_ENABLE_HDF5
     lfs     CGNS_ENABLE_LFS
     legacy  CGNS_ENABLE_LEGACY
#   INVERTED_FEATURES
#     tbb   ROCKSDB_IGNORE_PACKAGE_TBB
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
        -DHDF5_NEEDS_ZLIB=${CGNS_ENABLE_HDF5}
        -DHDF5_NEEDS_SZIP=${CGNS_ENABLE_HDF5}
        #-DHDF5_TOOLS_DIR=${CURRENT_INSTALLED_DIR}/tools/hdf5/
)

vcpkg_install_cmake()

file(INSTALL ${CURRENT_PACKAGES_DIR}/include/cgnsBuild.defs ${CURRENT_PACKAGES_DIR}/include/cgnsconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${CURRENT_PACKAGES_DIR}/include/cgnsconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT}/)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/cgnsBuild.defs ${CURRENT_PACKAGES_DIR}/include/cgnsconfig.h)

IF(EXISTS ${CURRENT_PACKAGES_DIR}/debug)
    file(INSTALL ${CURRENT_PACKAGES_DIR}/debug/include/cgnsconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT}/debug)
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
