vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DragonJoker/Ashes
    REF f39ca2db24a9d7a2d586c85c78bb6eacd8d63b49
    HEAD_REF master
    SHA512 a45d443797ffe31305acca154640530c6ed767af9982d857b6e59841add3b0a373723f5f7b590512c1b0dd4064dfbae8aa8445fec59a3c3c2b8a3c002b180609
)

vcpkg_from_github(
    OUT_SOURCE_PATH CMAKE_SOURCE_PATH
    REPO DragonJoker/CMakeUtils
    REF e2a9d422a02dab0e04f54b3e1bc515eba652a9d1
    HEAD_REF master
    SHA512 4ebd6141b9e5aa5283f31892da7108aa09fbd59292f0e98f2c9fe67577856f0af253184d41fdc16bb11094c4635401f181ea2e3abfa560adcf5c029f0d663b24
)

file(REMOVE_RECURSE "${SOURCE_PATH}/CMake")
file(COPY "${CMAKE_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/CMake")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DCMAKE_INSTALL_PREFIX=${CURRENT_INSTALLED_DIR}
        -DVCPKG_PACKAGE_BUILD=ON
        -DASHES_BUILD_TEMPLATES=OFF
        -DASHES_BUILD_TESTS=OFF
        -DASHES_BUILD_INFO=OFF
        -DASHES_BUILD_SAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ashes)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
