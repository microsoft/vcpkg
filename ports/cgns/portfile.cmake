
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGNS/CGNS
    REF 86b686bce292eef7782cfb56b6acdb5123c96f49 # v4.2.0
    SHA512 88df741acc1b650724bcbeb82ab0f7e593bf01e0a30c04b14b9915f4ea4331725cc24b87715dd08d93d5a3708660ca7f7874bc0a9c5505b76471802cf033e35d
    HEAD_REF develop
    PATCHES
        hdf5.patch
        linux_lfs.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
   FEATURES
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

file(INSTALL ${CURRENT_PORT_DIR}/cgnsconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include) # the include is all that is needed

set(TOOLS cgnscheck cgnscompress cgnsconvert cgnsdiff cgnslist cgnsnames)

foreach(tool ${TOOLS})
    set(suffix ${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/${tool}${suffix}")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${tool}${suffix}")
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${tool}${suffix}")
        file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/${tool}${suffix}"
                     DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${tool}${suffix}")
    endif()
endforeach()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

IF(EXISTS ${CURRENT_PACKAGES_DIR}/debug) 
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/include/cgnsBuild.defs ${CURRENT_PACKAGES_DIR}/debug/include/cgnsconfig.h)
endif()

file(REMOVE ${CURRENT_PACKAGES_DIR}/include/cgnsBuild.defs ${CURRENT_PACKAGES_DIR}/include/cgnsconfig.h)
file(GLOB_RECURSE BATCH_FILES ${CURRENT_PACKAGES_DIR}/bin/*.bat)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# # Moves all .cmake files from /debug/share/cgns/ to /share/cgns/
# # See /docs/maintainers/vcpkg_fixup_cmake_targets.md for more details
# vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/cgns)

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
