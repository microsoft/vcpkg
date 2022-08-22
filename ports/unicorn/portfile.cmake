if(VCPKG_CRT_LINKAGE STREQUAL "dynamic" AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "unicorn can currently only be built with /MT or /MTd (static CRT linkage)")
endif()

# Note: this is safe because unicorn is a C library and takes steps to avoid memory allocate/free across the DLL boundary.
set(VCPKG_CRT_LINKAGE "static")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unicorn-engine/unicorn
    REF 52f90cda023abaca510d59f021c88629270ad6c0 # v1.0.3
    SHA512 bb47e7d680b122e38bd9390f44a3f7e3c3e314ea3ac86dbab3e755b7bcc2db5daca3a4432276a874f59675f811f7785d68ec0d39696c955d3718d6a720adf70b
    HEAD_REF master
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(UNICORN_PLATFORM "Win32")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(UNICORN_PLATFORM "x64")
else()
    message(FATAL_ERROR "Unsupported architecture")
endif()

vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH "msvc/unicorn.sln"
    PLATFORM "${UNICORN_PLATFORM}"
    INCLUDES_SUBPATH "include/unicorn"
    LICENSE_SUBPATH "COPYING"
)

set(lib_suffix "")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(lib_suffix "_static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(GLOB PDLIBS "${CURRENT_PACKAGES_DIR}/debug/lib/*")
file(GLOB PRLIBS "${CURRENT_PACKAGES_DIR}/lib/*")
file(GLOB PDDLLS "${CURRENT_PACKAGES_DIR}/debug/bin/*")
file(GLOB PRDLLS "${CURRENT_PACKAGES_DIR}/bin/*")
list(FILTER PDLIBS EXCLUDE REGEX ".*/unicorn${lib_suffix}\\\.lib$")
list(FILTER PRLIBS EXCLUDE REGEX ".*/unicorn${lib_suffix}\\\.lib$")
list(FILTER PDDLLS EXCLUDE REGEX ".*/unicorn\\\.dll$")
list(FILTER PRDLLS EXCLUDE REGEX ".*/unicorn\\\.dll$")
file(REMOVE ${PDLIBS} ${PRLIBS} ${PDDLLS} ${PRDLLS})

file(
    INSTALL "${SOURCE_PATH}/COPYING_GLIB"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/unicorn"
)
