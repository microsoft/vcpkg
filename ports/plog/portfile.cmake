# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SergiusTheBest/plog
    REF 1.1.6
    SHA512 5240532df96144d5026d6f879b69f7d6f393ebc9122c6458c41076fd3db998565e45ed2ab4948f8c3cb59e08c0aad7695ee416f95b49fd70209cd937220cdf8b
    HEAD_REF master
)

# Copy header files
file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}" FILES_MATCHING PATTERN "*.h")

# Copy usage file
file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Put the licence file where vcpkg expects it
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
