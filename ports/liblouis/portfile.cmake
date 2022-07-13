set(VERSION 3.19.0)
set(VCPKG_BUILD_TYPE release)

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO liblouis/liblouis
        REF 10f66b2735b7d1e3e44d98f6dedbb859d197ea57 # v3.19.0
        SHA512 e085a1b53bb540b055bf70abe43e3c9e917de0683ea23e6c10a530f56f953fdb556efa51a21772ecb754d6d983af2b7f280935ae6d987b00f92a5ae841ef87cb
        PATCHES
            0002-CompileAndBuild.patch
        )
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO liblouis/liblouis
        REF 10f66b2735b7d1e3e44d98f6dedbb859d197ea57 # v3.19.0
        SHA512 e085a1b53bb540b055bf70abe43e3c9e917de0683ea23e6c10a530f56f953fdb556efa51a21772ecb754d6d983af2b7f280935ae6d987b00f92a5ae841ef87cb
        PATCHES
            0001-CompileAndBuild.patch
        )
        file(COPY ${CMAKE_CURRENT_LIST_DIR}/liblouis.def DESTINATION ${SOURCE_PATH}/windows)
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_build_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "windows"
        PROJECT_NAME "Makefile.nmake"
    )
else()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
    )

    vcpkg_install_make()
endif()

vcpkg_fixup_pkgconfig()
file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/tables" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/tables" "${CURRENT_PACKAGES_DIR}/share/${PORT}/braille-tables")
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/windows/liblouis.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/windows/liblouis.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)



