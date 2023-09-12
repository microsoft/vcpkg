vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IMQS/utfz
    REF v1.2
    SHA512 286a7a79fe860df8c5a4e1fc75f56460026fe9fbcd2f0ea3e70ecf78e4c5de73442a008339a90c2bd4ef94d5a89c0ed2fb537b91927f11aaa1aa5876d36a628b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

# Copy the include file
file(COPY "${SOURCE_PATH}/utfz.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/license" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
