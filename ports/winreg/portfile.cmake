# WinReg - Header-only library
vcpkg_fail_port_install(ON_TARGET "linux" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF ffb5ae9eb6609847c3a3a98d8da6192e2f67be79 #v3.0.1
    SHA512 6a9fecb09769a3d859d09421dd9c894fb1fe1ed90ede3eb899dba0a4c7a01f69192bd5b640bba6aea675de9e025a8121230f1e36d2354ed9fb79f1f2167299b4 
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY ${SOURCE_PATH}/WinReg/WinReg.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)