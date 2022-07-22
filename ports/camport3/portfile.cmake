vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO percipioxyz/camport3
    REF v1.6.2
    SHA512 e3b1fadb13b826e86aa174215430f5e4175aafd9a967f2401beb3768dcc489a8ce5a74c151d615bd3e34b837c81e201db55b290ef258612381141b0b94212fd1
    HEAD_REF master
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(COPY
    "${SOURCE_PATH}/include/TYApi.h"
    "${SOURCE_PATH}/include/TYCoordinateMapper.h"
    "${SOURCE_PATH}/include/TYImageProc.h"
    "${SOURCE_PATH}/include/TyIsp.h"
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
