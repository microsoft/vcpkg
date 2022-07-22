vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO freedesktop/libXpm
    REF 3425cbb0e6086f74783eafbe23df1121b655e006  #libXpm-v3.5.11
    SHA512 8c540171442cf6f8a770c5ba92bc3e4c032e834447ba62d9d35a545945c6fbe5b0ac10714e12e5a312e05cb5808ca8fb19c83c7223b530ae67cb4f1d650c4129
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()


file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
