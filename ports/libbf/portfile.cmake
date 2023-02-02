vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mavam/libbf
    REF v1.0.0
    SHA512 04db7adbeb4bc6b20aed7f2676840499ed1afe499b4cab67f27d4a0ad234c1fb06eced24259f37870ec4760fe74d6d6307b5d11b3cd928b975661eb2966d4db8
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
