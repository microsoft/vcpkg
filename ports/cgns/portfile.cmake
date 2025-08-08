vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGNS/CGNS
    REF "v${VERSION}"
    SHA512 0286ff2faf9102e5fb6d9bed764fd553756d62ae9be9dbb8b37ba6e2d3a7fec9337715320ec38a001960e39d397e846f2adbd4b54930c20e0304edacdd48fc92
    HEAD_REF develop
    PATCHES
        hdf5.patch
        install-lib-linkage.diff
        linux_lfs.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
   FEATURES
     "fortran"      CGNS_ENABLE_FORTRAN
     "hdf5"         CGNS_ENABLE_HDF5
     "lfs"          CGNS_ENABLE_LFS
     "legacy"       CGNS_ENABLE_LEGACY
     "tests"        CGNS_ENABLE_TESTS
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CGNS_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCGNS_BUILD_SHARED=${CGNS_BUILD_SHARED}
        -DCGNS_ENABLE_SCOPING:BOOL=ON
    OPTIONS_RELEASE
        -DCMAKE_TRY_COMPILE_CONFIGURATION=Release
    OPTIONS_DEBUG
        -DCMAKE_TRY_COMPILE_CONFIGURATION=Debug
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/cgns")

set(TOOLS "cgnsupdate")
if("hdf5" IN_LIST FEATURES)
    list(APPEND TOOLS "adf2hdf" "hdf2adf")
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    list(TRANSFORM TOOLS APPEND ".bat")
endif()
foreach(TOOL IN LISTS TOOLS)
    file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/${TOOL}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${TOOL}" "${CURRENT_PACKAGES_DIR}/debug/bin/${TOOL}")
endforeach()

vcpkg_copy_tools(
    TOOL_NAMES
        cgnscheck
        cgnscompress
        cgnsconvert
        cgnsdiff
        cgnslist
        cgnsnames
    AUTO_CLEAN
)

file(REMOVE "${CURRENT_PACKAGES_DIR}/include/cgnsBuild.defs" "${CURRENT_PACKAGES_DIR}/include/cgnsconfig.h")
file(INSTALL "${CURRENT_PORT_DIR}/cgnsconfig.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include") # the include is all that is needed

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/cgnslib.h" "defined(USE_DLL)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
