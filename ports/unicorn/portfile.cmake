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

vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH "msvc/unicorn.sln"
)

file(
    INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/msvc/distro/include/unicorn"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
    RENAME "unicorn"
)
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/COPYING"
    "${SOURCE_PATH}/COPYING_GLIB"
)

file(REMOVE
      "${CURRENT_PACKAGES_DIR}/debug/bin/Gee.External.Capstone.Proxy.dll"
      "${CURRENT_PACKAGES_DIR}/bin/Gee.External.Capstone.Proxy.dll"
      "${CURRENT_PACKAGES_DIR}/debug/bin/capstone.dll"
      "${CURRENT_PACKAGES_DIR}/bin/capstone.dll"
      ) # Import via nuget / used in samples

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
        "${CURRENT_PACKAGES_DIR}/lib/unicorn.lib"
        "${CURRENT_PACKAGES_DIR}/debug/lib/unicorn.lib"
    )
else()
    file(REMOVE
        "${CURRENT_PACKAGES_DIR}/lib/unicorn_static.lib"
        "${CURRENT_PACKAGES_DIR}/debug/lib/unicorn_static.lib"
    )
endif()

file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/COPYING.LIB" "${CURRENT_PACKAGES_DIR}/debug/lib/COPYING.LIB")
