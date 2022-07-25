vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gs1/gs1-barcode-engine
    REF 2021-09-10
    SHA512 dbffbbcdb945544d117e9b748bcf9640c13815e54dc55f6ab37ac5f9b0784dba1f6275993c2cad2a59626b97c575c2ecfb1a88d405d5b635d8102fa8a77bcfa6
    HEAD_REF master
    PATCHES
        runtime-lib.patch
)

if(VCPKG_TARGET_IS_WINDOWS)

    set(OPTIONS "")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        list(APPEND OPTIONS "/p:ConfigurationType=DynamicLibrary")
    else()
        list(APPEND OPTIONS "/p:ConfigurationType=StaticLibrary")
    endif()
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(RuntimeLibraryExt "")
    else()
        set(RuntimeLibraryExt "DLL")
    endif()
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH src/gs1encoders.sln
        LICENSE_SUBPATH LICENSE
        TARGET gs1encoders
        OPTIONS_DEBUG "/p:RuntimeLibrary=MultiThreadedDebug${RuntimeLibraryExt}"
        OPTIONS_RELEASE "/p:RuntimeLibrary=MultiThreaded${RuntimeLibraryExt}"
        OPTIONS ${OPTIONS}
        )
    file(INSTALL "${SOURCE_PATH}/src/c-lib/gs1encoders.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
else()
    vcpkg_configure_make(
        COPY_SOURCE
        SOURCE_PATH "${SOURCE_PATH}/src/c-lib"
    )

    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
