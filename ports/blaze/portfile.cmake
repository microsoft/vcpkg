#header-only library
include(vcpkg_common_functions)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO blaze-lib/blaze
    REF v3.2
    SHA512 f9a50c454125fe194f0d1fb259c5440c82068d41880a228fbd15fe383b6ef4198557daa406a08809065eedf223fc0c55d2309cc00ef549a3fc1a2a89e6d4b445
    HEAD_REF master
)

# Copy the blaze header files
file(COPY "${SOURCE_PATH}/blaze"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include"
     FILES_MATCHING PATTERN "*.h")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/blaze)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/blaze/LICENSE ${CURRENT_PACKAGES_DIR}/share/blaze/copyright)
