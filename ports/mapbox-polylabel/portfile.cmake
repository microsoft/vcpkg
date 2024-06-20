#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/polylabel
    REF v1.1.0
    SHA512 597920397969a1ae12fc2ad2bdd8143f32f6fa0b27b46a5fb6d7315b8456bbcb335e52c36277b50e3daa4658a0f3826863871df4f4a7868e923899af5832f783
    HEAD_REF master
)

# Copy header files
file(COPY "${SOURCE_PATH}/include/mapbox/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mapbox" FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
