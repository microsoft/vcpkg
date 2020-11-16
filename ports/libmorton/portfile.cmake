#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Forceflow/libmorton
    REF v0.2
    SHA512 04cf8332a1cee52eebfb25a46ac64517900704f62fe53ccf1d6a74c535ccac5af4e3ce2e0a5ce94ee850fadb429fe0d88d5a66901f16e4308341a621e599d33d
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmorton)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libmorton/LICENSE ${CURRENT_PACKAGES_DIR}/share/libmorton/copyright)

file(GLOB HEADER_FILES ${SOURCE_PATH}/libmorton/include/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/libmorton)
