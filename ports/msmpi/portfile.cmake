set(MSMPI_VERSION "10.1.12498")
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src/msmpi-${MSMPI_VERSION}")

vcpkg_download_distfile(SDK_ARCHIVE
    URLS "https://download.microsoft.com/download/a/5/2/a5207ca5-1203-491a-8fb8-906fd68ae623/msmpisdk.msi"
    FILENAME "msmpisdk-${MSMPI_VERSION}-b0087dfd.msi"
    SHA512 b0087dfd21423bf87b94b17d7cb03576838585371bbf8b03cca95c3ad73670108c7bc6517b0de852ef595072cc4143be2011636e7242bcb080394d94294848a7
)


#to enable CI, you should modify the following URL also in ${VCPKG_ROOT}/scripts/azure-pipelines/windows/provision-image.ps1
macro(download_msmpi_redistributable_package)
    vcpkg_download_distfile(REDIST_ARCHIVE
        URLS "https://download.microsoft.com/download/a/5/2/a5207ca5-1203-491a-8fb8-906fd68ae623/msmpisetup.exe"
        FILENAME "msmpisetup-${MSMPI_VERSION}.exe"
        SHA512 1ee463e7dfc3e55a7ac048fdfde13fef09a5eea4b74d8fd7c22a7aad667a025b467ce939e5de308e25bbc186c3fe66e0e24ac03a3741656fc7558f2af2fa132a
    )
endmacro()

### Check for correct version of installed redistributable package

# We always want the ProgramFiles folder even on a 64-bit machine (not the ProgramFilesx86 folder)
vcpkg_get_program_files_platform_bitness(PROGRAM_FILES_PLATFORM_BITNESS)
set(SYSTEM_MPIEXEC_FILEPATH "${PROGRAM_FILES_PLATFORM_BITNESS}/Microsoft MPI/Bin/mpiexec.exe")

if(EXISTS "${SYSTEM_MPIEXEC_FILEPATH}")
    set(MPIEXEC_VERSION_LOGNAME "mpiexec-version")
    vcpkg_execute_required_process(
        COMMAND ${SYSTEM_MPIEXEC_FILEPATH}
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME ${MPIEXEC_VERSION_LOGNAME}
    )
    file(READ "${CURRENT_BUILDTREES_DIR}/${MPIEXEC_VERSION_LOGNAME}-out.log" MPIEXEC_OUTPUT)

    if(MPIEXEC_OUTPUT MATCHES "\\[Version ([0-9]+\\.[0-9]+\\.[0-9]+)\\.[0-9]+\\]")
        if(NOT CMAKE_MATCH_1 STREQUAL MSMPI_VERSION)
            download_msmpi_redistributable_package()

            message(FATAL_ERROR
                "  The version of the installed MSMPI redistributable packages does not match the version to be installed\n"
                "    Expected version: ${MSMPI_VERSION}\n"
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
set(SCRIPT_FILE "${CURRENT_BUILDTREES_DIR}/msiextract-msmpi.bat")
# Write the command out to a script file and run that to avoid weird escaping behavior when spaces are present
file(WRITE ${SCRIPT_FILE} "msiexec ${PARAM_MSI} /qn ${PARAM_LOG} ${PARAM_TARGET_DIR}")

vcpkg_execute_required_process(
    COMMAND ${SCRIPT_FILE}
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
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
        "${CURRENT_PACKAGES_DIR}/include"
)

# NOTE: since the binary distribution does not include any debug libraries we always install the release libraries
SET(VCPKG_POLICY_ONLY_RELEASE_CRT enabled)

file(GLOB STATIC_LIBS
    "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifec.lib"
    "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifmc.lib"
    "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifes.lib"
    "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifms.lib"
)

file(INSTALL
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpi.lib"
    DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
)
file(INSTALL
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpi.lib"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
)

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    file(INSTALL ${STATIC_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL ${STATIC_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()


file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/mpi-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
file(COPY "${SOURCE_PATH}/sdk/PFiles/Microsoft SDKs/MPI/License/MicrosoftMPI-SDK-EULA.rtf" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${SOURCE_PATH}/sdk/PFiles/Microsoft SDKs/MPI/License/MPI-SDK-TPN.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "See the accompanying MicrosoftMPI-SDK-EULA.rtf and MPI-SDK-TPN.txt")
