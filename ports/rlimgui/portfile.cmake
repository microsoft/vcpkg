vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO raylib-extras/rlImGui
    REF "${VERSION}"
    SHA512 a1ad910eacd1a81da9dbcd57f4e59d90a982c010c6a847d2b421c39038cf46e7b4da5f8383f596d835bf08f9d2442ae413e8927b825ab1cdc711ad915978f118
    HEAD_REF main
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-rlImGui")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" [=[
find_package(unofficial-rlImGui CONFIG REQUIRED)
target_link_libraries(main PRIVATE unofficial::rlImGui::rlImGui)
]=])

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")