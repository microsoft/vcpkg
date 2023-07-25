vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO progsource/maddy
    REF f3d934d6ec70bd4c077acfb810026d5f15e11001 #1.1.2+20210419
    SHA512 7ac4c7e1077f2315c19945d994fa8c13538908f8b477d71c38c245826bff70987eb169eabdd756bfdd240be0f985f047298e0cd0706aaf5bc892bc9b0e804776
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
