vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dobiasd/FunctionalPlus
    REF v0.2.18-p0
    SHA512 119aaef75020ef06818bf5d33db8bce272e89d69699df9be636bc6fdf06b584e1842440896a431ea2a75b88ce01472f3a9886b8dd781f5e5533315e9ad6860ac
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFunctionalPlus_INSTALL_CMAKEDIR=share/FunctionalPlus
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
