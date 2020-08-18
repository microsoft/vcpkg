# WinReg - Header-only library
vcpkg_fail_port_install(ON_TARGET "linux" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GiovanniDicanio/WinReg
    REF d59fd46431f0c7ca5e3339918455b831c63bba25 #v3.1.0
    SHA512 98dea669415dcb4e577c92506050a9defab5ac5f70e9d783d0b379297d84e0e2b56afc230b86ff190421a0d54b283e7abe72bb3cf53ecfe3fbe90f29c335e08c
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY ${SOURCE_PATH}/WinReg/WinReg.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)