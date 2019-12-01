# Get nvcodec
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FFmpeg/nv-codec-headers
    REF n9.0.18.1
    SHA512 4306ee3c6e72e9e3172b28c5e6166ec3fb9dfdc32578aebda0588afc682f56286dd6f616284c9892907cd413f57770be3662572207a36d6ac65c75a03d381f6f
    HEAD_REF master
)

# ====================================================
# Install the pkgconfig info the `nccodec` package
# ====================================================
if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(BUILD_SCRIPT ${CMAKE_CURRENT_LIST_DIR}\build.sh)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES make pkg-config)
    set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)

    message(STATUS "Building ${_csc_PROJECT_PATH} for Release")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})

    # Build script parameters:
    # source root
    # msys root
    vcpkg_execute_required_process(
        COMMAND ${BASH} --noprofile --norc "${BUILD_SCRIPT}"
            "${SOURCE_PATH}" # SOURCE DIR
            "${CURRENT_PACKAGES_DIR}" # PACKAGE DIR
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}
        LOGNAME build-${TARGET_TRIPLET}
    )

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
    file(INSTALL ${SOURCE_PATH}/ffnvcodec.pc DESTINATION ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
endif()

# == Windows ========================
# Run make in the msys environment so FFmpeg can find it there
# A. Get msys
# B. Run a bash script that will run make and install the headers in the msys environment
# (In Windows we may  need to create a dummy location to avoid conflicts with other include directories)


# Install the files to their generic location regardless
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})
file(INSTALL ${CURRENT_PORT_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/ffnvcodec)
