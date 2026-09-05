vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO morganstanley/modern-cpp-kafka
    REF "v${VERSION}"
    SHA512 a6a921cc5037baaa0632fed350b4b5a3d5d47116397ae2638f9121997dbf7842d6406a889833ae551d738cd1bb189c5cec152b14f59644aec38ac9b6b5883a0b
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only port

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(READ "${CURRENT_PACKAGES_DIR}/share/unofficial-modern-cpp-kafka/unofficial-modern-cpp-kafka-config.cmake" cmake_config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-modern-cpp-kafka/unofficial-modern-cpp-kafka-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(RdKafka CONFIG)
find_dependency(Boost)
find_dependency(RapidJSON CONFIG)
${cmake_config}
")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
