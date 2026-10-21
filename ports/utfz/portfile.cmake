vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IMQS/utfz
    REF v${VERSION}
    SHA512 d8451c003e658fe342f0f4d6f20114784a671ec59fe04a7c17c8889849110fc8ee5370449bfc9f9816f449bc629d51f6bc4d23e2e4b7bfc9ef6dd41f35a79ba0
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
