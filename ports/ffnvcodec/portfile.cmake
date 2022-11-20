vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FFmpeg/nv-codec-headers
    REF b641a195edbe3ac9788e681e22c2e2fad8aacddb # 11.1.5.0
    SHA512 e8b4c21ddc9c39dadd9b69ebdfcf38cf1e61f19ffb88d0a4d9086ddbf69285d2c8c946bb02bde3ee943accae559a72468f096718ad69ac03a43746c1eb0ed483
    HEAD_REF master
)

# ====================================================
# Install the pkgconfig info for the `nvcodec` package
# ====================================================

# Windows
if(VCPKG_TARGET_IS_WINDOWS)
    set(BUILD_SCRIPT ${CMAKE_CURRENT_LIST_DIR}\\build.sh)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES make pkg-config)
    set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)

    message(STATUS "Building ${_csc_PROJECT_PATH} for Release")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})

    # Make and deploy the ffnvcodec.pc file using MSYS
    # (so that FFmpeg can find it in the MSYS rootfs)
    vcpkg_execute_required_process(
        COMMAND ${BASH} --noprofile --norc "${BUILD_SCRIPT}"
            "${SOURCE_PATH}"
            "${CURRENT_PACKAGES_DIR}"
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}
        LOGNAME build-${TARGET_TRIPLET}
    )
    
    file(INSTALL "${SOURCE_PATH}/ffnvcodec.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")

# Linux, etc.
else()
    FIND_PROGRAM(MAKE make)
    IF (NOT MAKE)
        MESSAGE(FATAL_ERROR "MAKE not found")
    ENDIF ()
    
    vcpkg_execute_required_process(
        COMMAND make PREFIX=$${CURRENT_PACKAGES_DIR}
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME make-${TARGET_TRIPLET}
    )

    # FFmpeg uses pkgconfig to find ffnvcodec.pc, so install it where 
    # FFMpeg's call to pkgconfig expects to find it.
    file(INSTALL "${SOURCE_PATH}/ffnvcodec.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
    file(INSTALL "${SOURCE_PATH}/ffnvcodec.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()

vcpkg_fixup_pkgconfig()

# Install the files to their default vcpkg locations
file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")
file(INSTALL "${CURRENT_PORT_DIR}/copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
