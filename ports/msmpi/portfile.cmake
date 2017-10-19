include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/msmpi-8.1)

vcpkg_download_distfile(SDK_ARCHIVE
    URLS "https://download.microsoft.com/download/D/B/B/DBB64BA1-7B51-43DB-8BF1-D1FB45EACF7A/msmpisdk.msi"
    FILENAME "msmpisdk-8.1.msi"
    SHA512 a0cfb713865257b812c19644286fc0d02ec57ce2a0bea066fead4e0ff18b545a0787065ab748f8dd335bb2fa486911aab54c1b842993b7b685c5832c014a63bf
)

macro(download_msmpi_redistributable_package)
    vcpkg_download_distfile(REDIST_ARCHIVE
        URLS "https://download.microsoft.com/download/D/B/B/DBB64BA1-7B51-43DB-8BF1-D1FB45EACF7A/MSMpiSetup.exe"
        FILENAME "MSMpiSetup-8.1.exe"
        SHA512 92ae65f3d52e786e39dffedabdf48255b4985a075993e626f5f59674e9ffaedbf33a4725e8f142b21468e24cd6d3e49f3d91da0fbda1867784cc93300c12c96b
    )
endmacro()

### Check for correct version of installed redistributable package

# We always want the ProgramFiles folder even on a 64-bit machine (not the ProgramFilesx86 folder)
vcpkg_get_program_files_platform_bitness(PROGRAM_FILES_PLATFORM_BITNESS)
set(SYSTEM_MPIEXEC_FILEPATH "${PROGRAM_FILES_PLATFORM_BITNESS}/Microsoft MPI/Bin/mpiexec.exe")
set(MSMPI_EXPECTED_FULL_VERSION "8.1.12438.1084")

if(EXISTS "${SYSTEM_MPIEXEC_FILEPATH}")
    set(MPIEXEC_VERSION_LOGNAME "mpiexec-version")
    vcpkg_execute_required_process(
        COMMAND ${SYSTEM_MPIEXEC_FILEPATH}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
        LOGNAME ${MPIEXEC_VERSION_LOGNAME}
    )
    file(READ ${CURRENT_BUILDTREES_DIR}/${MPIEXEC_VERSION_LOGNAME}-out.log MPIEXEC_OUTPUT)

    if(MPIEXEC_OUTPUT MATCHES "\\[Version ([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)\\]")
        if(NOT CMAKE_MATCH_1 STREQUAL MSMPI_EXPECTED_FULL_VERSION)
            download_msmpi_redistributable_package()

            message(FATAL_ERROR
                "  The version of the installed MSMPI redistributable packages does not match the version to be installed\n"
                "    Expected version: ${MSMPI_EXPECTED_FULL_VERSION}\n"
                "    Found version: ${CMAKE_MATCH_1}\n"
                "  Please upgrade the installed version on your system.\n"
                "  The appropriate installer for the expected version has been downloaded to:\n"
                "    ${REDIST_ARCHIVE}\n")
        endif()
    else()
        message(FATAL_ERROR
            "  Could not determine installed MSMPI redistributable package version.\n"
            "  See logs for more information:\n"
            "    ${CURRENT_BUILDTREES_DIR}\\${MPIEXEC_VERSION_LOGNAME}-out.log\n"
            "    ${CURRENT_BUILDTREES_DIR}\\${MPIEXEC_VERSION_LOGNAME}-err.log\n")
    endif()
else()
    download_msmpi_redistributable_package()

    message(FATAL_ERROR
        "  Could not find:\n"
        "    ${SYSTEM_MPIEXEC_FILEPATH}\n"
        "  Please install the MSMPI redistributable package before trying to install this port.\n"
        "  The appropriate installer has been downloaded to:\n"
        "    ${REDIST_ARCHIVE}\n")
endif()

file(TO_NATIVE_PATH "${SDK_ARCHIVE}" SDK_ARCHIVE)
file(TO_NATIVE_PATH "${SOURCE_PATH}/sdk" SDK_SOURCE_DIR)
file(TO_NATIVE_PATH "${CURRENT_BUILDTREES_DIR}/msiexec-${TARGET_TRIPLET}.log" MSIEXEC_LOG_PATH)

set(PARAM_MSI "/a \"${SDK_ARCHIVE}\"")
set(PARAM_LOG "/log \"${MSIEXEC_LOG_PATH}\"")
set(PARAM_TARGET_DIR "TARGETDIR=\"${SDK_SOURCE_DIR}\"")
set(SCRIPT_FILE ${CURRENT_BUILDTREES_DIR}/msiextract-msmpi.bat)
# Write the command out to a script file and run that to avoid weird escaping behavior when spaces are present
file(WRITE ${SCRIPT_FILE} "msiexec ${PARAM_MSI} /qn ${PARAM_LOG} ${PARAM_TARGET_DIR}")

vcpkg_execute_required_process(
    COMMAND ${SCRIPT_FILE}
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME extract-sdk
)

set(SOURCE_INCLUDE_PATH "${SOURCE_PATH}/sdk/PFiles/Microsoft SDKs/MPI/Include")
set(SOURCE_LIB_PATH "${SOURCE_PATH}/sdk/PFiles/Microsoft SDKs/MPI/Lib")

# Install include files
file(INSTALL
        "${SOURCE_INCLUDE_PATH}/mpi.h"
        "${SOURCE_INCLUDE_PATH}/mpif.h"
        "${SOURCE_INCLUDE_PATH}/mpi.f90"
        "${SOURCE_INCLUDE_PATH}/mpio.h"
        "${SOURCE_INCLUDE_PATH}/mspms.h"
        "${SOURCE_INCLUDE_PATH}/pmidbg.h"
        "${SOURCE_INCLUDE_PATH}/${TRIPLET_SYSTEM_ARCH}/mpifptr.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include
)

# Install release libraries
file(INSTALL
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpi.lib"
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifec.lib"
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifmc.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/lib
)
if(TRIPLET_SYSTEM_ARCH STREQUAL "x86")
    file(INSTALL
            "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifes.lib"
            "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifms.lib"
        DESTINATION
            ${CURRENT_PACKAGES_DIR}/lib
    )
endif()

# Install debug libraries
# NOTE: since the binary distribution does not include any debug libraries we simply install the release libraries
SET(VCPKG_POLICY_ONLY_RELEASE_CRT enabled)
file(INSTALL
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpi.lib"
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifec.lib"
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifmc.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/debug/lib
)
if(TRIPLET_SYSTEM_ARCH STREQUAL "x86")
    file(INSTALL
            "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifes.lib"
            "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifms.lib"
        DESTINATION
            ${CURRENT_PACKAGES_DIR}/debug/lib
    )
endif()

# Handle copyright
file(COPY "${SOURCE_PATH}/sdk/PFiles/Microsoft SDKs/MPI/License/license_sdk.rtf" DESTINATION ${CURRENT_PACKAGES_DIR}/share/msmpi)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/msmpi/copyright "See the accompanying license_sdk.rtf")
