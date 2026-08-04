vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ai-finder-for-api/easy-vulkan-gui
    REF 0.04
    SHA512 739dde6585023dd8467192f694b7dbcd6c29d997abad87e035d2bea65955bfd3ef90666e7e1039be86bfbbdd60527ae556aa66ea6eeb57f6e871f0939d523b4d
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)