vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO percipioxyz/camport3
    REF v1.5.3
    SHA512 efa41e75b4ed7147f94270765138aa226a92ec51c99157776e916ec178ad2a9fe55aa6e6e746be46e2f2178852f4c4f9323b515f5a1b151ac70c21f8f923d901
    HEAD_REF master
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(COPY
    ${SOURCE_PATH}/include/TYApi.h
    ${SOURCE_PATH}/include/TYCoordinateMapper.h
    ${SOURCE_PATH}/include/TYImageProc.h
    ${SOURCE_PATH}/include/TyIsp.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include)

if(VCPKG_TARGET_IS_WINDOWS)
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib)
        file(COPY
            ${SOURCE_PATH}/lib/win/hostapp/${VCPKG_TARGET_ARCHITECTURE}/tycam.lib
            DESTINATION ${CURRENT_PACKAGES_DIR}/lib
        )
        file(COPY
            ${SOURCE_PATH}/lib/win/hostapp/${VCPKG_TARGET_ARCHITECTURE}/tycam.dll
            DESTINATION ${CURRENT_PACKAGES_DIR}/bin
        )
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib)
        file(COPY
            ${SOURCE_PATH}/lib/win/hostapp/${VCPKG_TARGET_ARCHITECTURE}/tycam.lib
            DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
        )
        file(COPY
            ${SOURCE_PATH}/lib/win/hostapp/${VCPKG_TARGET_ARCHITECTURE}/tycam.dll
            DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
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
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib)
        file(COPY
            ${SOURCE_PATH}/lib/linux/lib_${CAMPORT3_ARCH}/libtycam.so
            DESTINATION ${CURRENT_PACKAGES_DIR}/lib
        )
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib)
        file(COPY
            ${SOURCE_PATH}/lib/linux/lib_${CAMPORT3_ARCH}/libtycam.so
            DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
        )
    endif()

endif()

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)
