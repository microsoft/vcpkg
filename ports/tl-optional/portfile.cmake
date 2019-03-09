include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TartanLlama/optional
    REF v0.5
    SHA512 f4f72c1ba431737fb7b1b6468b7dbbb025f299775e0a3401993490a60d5999d31ccf1e48c0cd57836293a5534ea4749b9f1c8f65f896144204af3389a5e512f9
    HEAD_REF master
)

# Install header file
file(INSTALL ${SOURCE_PATH}/tl DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/tl-optional RENAME copyright)
