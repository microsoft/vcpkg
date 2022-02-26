
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Headers
    REF f75fc98badb2bd585390aeae613a2cdbb2ff3310
    SHA512 3aac7c29609fa309e33cb1cbd7149d45c187024291c7a54ccf65b231473745a06b658f4cbb201f69fe177ab31d0c16612ae097a96a93091862596c5957a9294d
    HEAD_REF master
)

# This must be spirv as other spirv packages expect it there.
file(COPY "${SOURCE_PATH}/include/spirv/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/spirv")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
