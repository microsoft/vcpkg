vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cwapi3d/cwapi3dcpp
    REF 68fba49c5f99bb1b4e0b6f7ea285ee2805311821
    SHA512 275a85d80b50ce71b19e7005a6a3db5079dfdd2f50a8f2f710746e6e12ba38d610fbd478c22a49127228648be7cf00b7a8e2ece9de830670124327e880d031dc
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/CwAPI3D)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
