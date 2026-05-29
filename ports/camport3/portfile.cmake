vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO percipioxyz/camport3
    REF "v${VERSION}"
    SHA512 9d2ab3fdf4c46ca92afbf3c2ebc171df0a29415956e3a4325a4e5146d128e886c09f3b992fbad4c759cadcf22c08d149bb6c37fe33a27accacc66dc71b2b1dfa
    HEAD_REF master
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(COPY
    "${SOURCE_PATH}/include/TYApi.h"
    "${SOURCE_PATH}/include/TYCoordinateMapper.h"
    "${SOURCE_PATH}/include/TYDefs.h"
    "${SOURCE_PATH}/include/TYImageProc.h"
    "${SOURCE_PATH}/include/TyIsp.h"
    "${SOURCE_PATH}/include/TYVer.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include")

if(VCPKG_TARGET_IS_WINDOWS)
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib")
        file(COPY
            "${SOURCE_PATH}/lib/win/hostapp/${VCPKG_TARGET_ARCHITECTURE}/tycam.lib"
            DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
        )
        file(COPY
            "${SOURCE_PATH}/lib/win/hostapp/${VCPKG_TARGET_ARCHITECTURE}/tycam.dll"
            DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
        )
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
        file(COPY
            "${SOURCE_PATH}/lib/win/hostapp/${VCPKG_TARGET_ARCHITECTURE}/tycam.lib"
            DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
        )
        file(COPY
            "${SOURCE_PATH}/lib/win/hostapp/${VCPKG_TARGET_ARCHITECTURE}/tycam.dll"
            DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin"
        )
    endif()

elseif(VCPKG_TARGET_IS_LINUX)
    if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set (CAMPORT3_ARCH "Aarch64")
    elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set (CAMPORT3_ARCH "armv7hf")
    elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set (CAMPORT3_ARCH "i686")
    else()
        set (CAMPORT3_ARCH ${VCPKG_TARGET_ARCHITECTURE})
    endif()

    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib")
        file(COPY
            "${SOURCE_PATH}/lib/linux/lib_${CAMPORT3_ARCH}/libtycam.so"
            DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
        )
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
        file(COPY
            "${SOURCE_PATH}/lib/linux/lib_${CAMPORT3_ARCH}/libtycam.so"
            DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
        )
    endif()

endif()

file(INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
