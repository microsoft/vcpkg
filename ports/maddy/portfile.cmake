vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO progsource/maddy
    REF "${VERSION}"
    SHA512 a99d0d5db1ada9d6238b714d90d9146fbb49f76ef150f180ea19e554eb15463ca4dfbece289cff501a48e72445757059a6cc4629a20ac3c7756ac10fc93d097d
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
