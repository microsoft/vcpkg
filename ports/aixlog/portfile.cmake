vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO badaix/aixlog
    REF fd4a341740ee840092963de852584ec8ff811c4f # v1.5.0
    SHA512 10ab07dcb1e67064c0d69ddcf9289d79d914c70fe6922f32179f9ac38d5c682a4ebe08b686d8160c699a6b966bc7aa2fd7d0268664570a10ce146850e78b292d
    )

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
   
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
