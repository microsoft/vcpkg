include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/msmpi-8.0)

vcpkg_download_distfile(SDK_ARCHIVE
    URLS "https://download.microsoft.com/download/B/2/E/B2EB83FE-98C2-4156-834A-E1711E6884FB/msmpisdk.msi"
    FILENAME "msmpisdk-8.0.msi"
    SHA512 49c762873ba777ccb3c959a1d2ca1392e4c3c8d366e604ad707184ea432302e6649894ec6599162d0d40f3e6ebc0dada1eb9ca0da1cde0f6ba7a9b1847dac8c0
)

### Check for correct version of installed redistributable package

# We always want the ProgramFiles folder even on a 64-bit machine (not the ProgramFilesx86 folder)
vcpkg_get_program_files_platform_bitness(PROGRAM_FILES_PLATFORM_BITNESS)
set(SYSTEM_MPIEXEC_FILEPATH "${PROGRAM_FILES_PLATFORM_BITNESS}/Microsoft MPI/Bin/mpiexec.exe")
set(MSMPI_EXPECTED_FULL_VERSION "8.0.12438.0")

if(EXISTS ${SYSTEM_MPIEXEC_FILEPATH})
    set(MPIEXEC_VERSION_LOGNAME "mpiexec-version")
    vcpkg_execute_required_process(
        COMMAND ${SYSTEM_MPIEXEC_FILEPATH}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
        LOGNAME ${MPIEXEC_VERSION_LOGNAME}
    )
    file(READ ${CURRENT_BUILDTREES_DIR}/${MPIEXEC_VERSION_LOGNAME}-out.log MPIEXEC_OUTPUT)

    if(${MPIEXEC_OUTPUT} MATCHES "\\[Version ([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)\\]")
        if(NOT ${CMAKE_MATCH_1} STREQUAL ${MSMPI_EXPECTED_FULL_VERSION})
            message(FATAL_ERROR
                "  The version of the installed MSMPI redistributable packages does not match the version to be installed\n"
                "  Expected version: ${MSMPI_EXPECTED_FULL_VERSION}\n"
                "  Found version: ${CMAKE_MATCH_1}\n")
        endif()
    else()
        message(FATAL_ERROR
            "  Could not determine installed MSMPI redistributable package version.\n"
            "  See logs for more information:\n"
            "    ${CURRENT_BUILDTREES_DIR}\\${MPIEXEC_VERSION_LOGNAME}-out.log\n"
            "    ${CURRENT_BUILDTREES_DIR}\\${MPIEXEC_VERSION_LOGNAME}-err.log\n")
    endif()
else()
    vcpkg_download_distfile(REDIST_ARCHIVE
        URLS "https://download.microsoft.com/download/B/2/E/B2EB83FE-98C2-4156-834A-E1711E6884FB/MSMpiSetup.exe"
        FILENAME "MSMpiSetup-8.0.exe"
        SHA512 f5271255817f5417de8e432cd21e5ff3c617911a30b7777560c0ceb6f4031ace5fa88fc7675759ae0964bcf4e2076fe367a06c129f3a9ad06871a08bf95ed68b
    )

    message(FATAL_ERROR
        "  Could not find:\n"
        "    ${SYSTEM_MPIEXEC_FILEPATH}\n"
        "  Please install the MSMPI redistributable package before trying to install this port.\n"
        "  The appropriate installer has been downloaded to:\n"
        "    ${REDIST_ARCHIVE}\n")
endif()

file(TO_NATIVE_PATH "${SDK_ARCHIVE}" SDK_ARCHIVE)
file(TO_NATIVE_PATH "${SOURCE_PATH}/sdk" SDK_SOURCE_DIR)

vcpkg_execute_required_process(
    COMMAND msiexec /a ${SDK_ARCHIVE} /qn TARGETDIR=${SDK_SOURCE_DIR}
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
if(${TRIPLET_SYSTEM_ARCH} STREQUAL "x86")
    file(INSTALL
            "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifes.lib"
            "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifms.lib"
        DESTINATION
            ${CURRENT_PACKAGES_DIR}/lib
    )
endif()

# Install debug libraries
# NOTE: since the binary distribution does not include any debug libraries we simply install the release libraries
file(INSTALL
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpi.lib"
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifec.lib"
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifmc.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/debug/lib
)
if(${TRIPLET_SYSTEM_ARCH} STREQUAL "x86")
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
