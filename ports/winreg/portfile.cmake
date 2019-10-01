# WinReg - Header-only library

include(vcpkg_common_functions)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    message("winreg only support windows.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF v1.2.1
    SHA512 c919f91bf37b2fd7c30f6463430e07f3b8d1a01b8d4c84591b56299faf9d5b651d7c3b35a2adc22e3b0aa471627060a45e179f98f309242683b17d4d0d81cb7b 
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY ${SOURCE_PATH}/WinReg/WinReg/WinReg.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)