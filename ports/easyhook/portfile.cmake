vcpkg_fail_port_install(ON_TARGET "Linux" "OSX" "UWP" ON_ARCH "arm" ON_LIBRARY_LINKAGE "static")

message(WARNING ".Net framework 4.0 is required, please install it before install easyhook.")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO EasyHook/EasyHook
    REF v2.7.7097.0
    SHA512 D0CA5B64E77F6281B2DD7EE0DC492A9B07DDB60A9F514037938CC3E3FFA5DD57C95CB630E18C02C984A89070839E4188044896D4EE57A21E43E6EA3A4918255A
    HEAD_REF master
    PATCHES fix-build.patch
)

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(BUILD_ARCH "Win32")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(BUILD_ARCH "x64")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH EasyHook.sln
	TARGET EasyHookDll
    RELEASE_CONFIGURATION "netfx4-Release"
    DEBUG_CONFIGURATION "netfx4-Debug"
    PLATFORM ${BUILD_ARCH}
)

# Remove the mismatch rebuild library
if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/AUX_ULIB_x64.LIB")
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/AUX_ULIB_x64.LIB")
    endif()
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/AUX_ULIB_x86.LIB")
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/AUX_ULIB_x86.LIB")
    endif()
endif()

# These libraries are useless, so remove.
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/EasyHook.dll" "${CURRENT_PACKAGES_DIR}/bin/EasyHook.pdb")
endif()
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/EasyHook.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/EasyHook.pdb")
endif()

# Install includes
file(INSTALL "${SOURCE_PATH}/Public/easyhook.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/easyhook")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
