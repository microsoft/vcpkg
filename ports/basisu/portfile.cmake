vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jherico/basis_universal
    REF 497875f756ed0e3eb62e0ff08d55c62242f4be74
    SHA512 2293b78620a7ed510dbecf48bcae5f4b8524fe9020f864c8e79cf94ea9d95d51dddf83a5b4ea29cc95db19f87137bfef1cb68b7fbc6387e08bb42898d81c9303
    HEAD_REF master
    PATCHES fix-addostream.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES "basisu_tool" AUTO_CLEAN)

# Remove unnecessary files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
