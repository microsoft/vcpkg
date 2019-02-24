include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jedisct1/libsodium
    REF 1.0.17
    SHA512 faf6ab57d113b6b1614b51390823a646f059018327b6f493e9e918a908652d0932a75a1a6683032b7a3869f516f387d67acdf944568387feddff7b2f5b6e77d6
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
    ${CMAKE_CURRENT_LIST_DIR}/disable-tests.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(LIBSODIUM_RELEASE_CONFIGURATION ReleaseDLL)
    set(LIBSODIUM_DEBUG_CONFIGURATION DebugDLL)
else()
    set(LIBSODIUM_RELEASE_CONFIGURATION Release)
    set(LIBSODIUM_DEBUG_CONFIGURATION Debug)
endif()

IF(VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    SET(BUILD_ARCH "Win32")
ELSE()
    SET(BUILD_ARCH ${VCPKG_TARGET_ARCHITECTURE})
ENDIF()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/libsodium.vcxproj
    RELEASE_CONFIGURATION ${LIBSODIUM_RELEASE_CONFIGURATION}
    DEBUG_CONFIGURATION ${LIBSODIUM_DEBUG_CONFIGURATION}
    OPTIONS
        /p:ForceImportBeforeCppTargets=${SOURCE_PATH}/builds/msvc/properties/${BUILD_ARCH}.props
)

file(INSTALL
    ${SOURCE_PATH}/src/libsodium/include/sodium.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(GLOB LIBSODIUM_HEADERS "${SOURCE_PATH}/src/libsodium/include/sodium/*.h")
file(INSTALL
    ${LIBSODIUM_HEADERS}
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/sodium
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(READ ${CURRENT_PACKAGES_DIR}/include/sodium/export.h _contents)
    string(REPLACE "#ifdef SODIUM_STATIC" "#if 1 //#ifdef SODIUM_STATIC" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/sodium/export.h "${_contents}")
endif ()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(INSTALL
        ${SOURCE_PATH}/Build/${LIBSODIUM_RELEASE_CONFIGURATION}/${BUILD_ARCH}/libsodium.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )
    file(INSTALL
    ${SOURCE_PATH}/Build/${LIBSODIUM_DEBUG_CONFIGURATION}/${BUILD_ARCH}/libsodium.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )
endif()

file(INSTALL
    ${SOURCE_PATH}/Build/${LIBSODIUM_RELEASE_CONFIGURATION}/${BUILD_ARCH}/libsodium.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(INSTALL
    ${SOURCE_PATH}/Build/${LIBSODIUM_DEBUG_CONFIGURATION}/${BUILD_ARCH}/libsodium.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)

vcpkg_copy_pdbs()

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/libsodium
    RENAME copyright
)
