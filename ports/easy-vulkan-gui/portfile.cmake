vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ai-finder-for-api/easy-vulkan-gui
    REF 0.06
    SHA512 2ee1a5df82c5d49204074e0ecf85742370b2255c4e1375831175f457341f2f80eb5dafa9182c4a2f0e3d48a22c9530acc5a931ef560538edad9cf3c3940b47fe
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)