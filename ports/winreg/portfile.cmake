# WinReg - Header-only library
vcpkg_fail_port_install(ON_TARGET "linux" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF 5102b656389aa2909ca69d74e8b694e8451d85b1 #v2.2.2
    SHA512 3f46eccf5bcc76c71848463ac898953bb8d7737200ea55900f064ad95da6953e643233f7faa5c3288fa42cbb599da62b324abaec3509dfa969430c464ac586fe 
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY ${SOURCE_PATH}/WinReg/WinReg.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)