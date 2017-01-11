include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/msmpi-7.1)

vcpkg_find_acquire_program(7Z)

vcpkg_download_distfile(SDK_ARCHIVE
    URLS "https://download.microsoft.com/download/E/8/A/E8A080AF-040D-43FF-97B4-065D4F220301/msmpisdk.msi"
    FILENAME "msmpisdk-7.1.msi"
    SHA512 e3b479189e0effc83c030c74ac6e6762f577cfa94bffb2b35192aab3329b5cfad7933c353c0304754e6b097912b81dbfd4d4b52a5fe5563bd4f3578cd1cf71d7
)
vcpkg_download_distfile(REDIST_ARCHIVE
    URLS "https://download.microsoft.com/download/E/8/A/E8A080AF-040D-43FF-97B4-065D4F220301/MSMpiSetup.exe"
    FILENAME "MSMpiSetup-7.1.exe"
    SHA512 f75c448e49b1ab4f5e60c958f0c7c1766e06665d65d2bdec42578aa77fb9d5fdc0215cee6ec51909e77d13451490bfff1c324bf9eb4311cb886b98a6ad469a2d
)

file(TO_NATIVE_PATH "${SDK_ARCHIVE}" SDK_ARCHIVE)
file(TO_NATIVE_PATH "${SOURCE_PATH}/sdk" SDK_SOURCE_DIR)

vcpkg_execute_required_process(
    COMMAND msiexec /a ${SDK_ARCHIVE} /qn TARGETDIR=${SDK_SOURCE_DIR}
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME extract-sdk
)

vcpkg_execute_required_process(
    COMMAND ${7Z} e -o${SOURCE_PATH}/redist -aoa ${REDIST_ARCHIVE}
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME extract-redist
)

set(SOURCE_INCLUDE_PATH "${SOURCE_PATH}/sdk/PFiles/Microsoft SDKs/MPI/Include")
set(SOURCE_LIB_PATH "${SOURCE_PATH}/sdk/PFiles/Microsoft SDKs/MPI/Lib")
set(SOURCE_BIN_PATH "${SOURCE_PATH}/redist")

# Install include files
file(INSTALL
        "${SOURCE_INCLUDE_PATH}/mpi.h"
        "${SOURCE_INCLUDE_PATH}/mpif.h"
        "${SOURCE_INCLUDE_PATH}/mpi.f90"
        "${SOURCE_INCLUDE_PATH}/${TRIPLET_SYSTEM_ARCH}/mpifptr.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include
)

# NOTE: we do not install the dlls here since they are not architecture independent (x86 only)
#       and they seam not to be required by neither mpiexec nor programs build against msmpi.lib

# Install release libraries and tools
file(INSTALL
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpi.lib"
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifec.lib"
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifmc.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/lib
)
# file(INSTALL
#         "${SOURCE_BIN_PATH}/msmpi.dll"
#         "${SOURCE_BIN_PATH}/msmpires.dll"
#     DESTINATION
#         ${CURRENT_PACKAGES_DIR}/bin
# )

# Install debug libraries
# NOTE: since the binary distribution does not include any debug libraries we simply install the release libraries
file(INSTALL
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpi.lib"
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifec.lib"
        "${SOURCE_LIB_PATH}/${TRIPLET_SYSTEM_ARCH}/msmpifmc.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/debug/lib
)
# file(INSTALL
#         "${SOURCE_BIN_PATH}/msmpi.dll"
#         "${SOURCE_BIN_PATH}/msmpires.dll"
#     DESTINATION
#         ${CURRENT_PACKAGES_DIR}/debug/bin
# )

# Install tools
file(INSTALL
        "${SOURCE_BIN_PATH}/mpiexec.exe"
        "${SOURCE_BIN_PATH}/msmpilaunchsvc.exe"
        "${SOURCE_BIN_PATH}/smpd.exe"
        "${SOURCE_BIN_PATH}/mpitrace.man"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/tools
)

# Handle copyright
file(COPY "${SOURCE_PATH}/sdk/PFiles/Microsoft SDKs/MPI/License/license_sdk.rtf" DESTINATION ${CURRENT_PACKAGES_DIR}/share/msmpi)
#TODO: convert RTF to simple text?!
file(RENAME ${CURRENT_PACKAGES_DIR}/share/msmpi/license_sdk.rtf ${CURRENT_PACKAGES_DIR}/share/msmpi/copyright)
