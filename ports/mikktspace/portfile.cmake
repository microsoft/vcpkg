vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mmikk/MikkTSpace
    REF 3e895b49d05ea07e4c2133156cfa94369e19e409
    SHA512 3ca433bd4efd0e048138f9efc5ba9021e4f3f78a535ea48733088ba5f43e60aad7f840f00e0597a0c053cda4776177bf6deb14cecf4d172b9b68acf00d5a1ca7
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DMIKKTSPACE_SKIP_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(INSTALL "${SOURCE_PATH}/mikktspace.h" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
