vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO morganstanley/modern-cpp-kafka
    REF "v${VERSION}"
    SHA512 5071ba4aeb80d94fd078df054e3a36249e2e433bda2af4c26686cd5b0615d622cfd964c7193d075cc549a572cfa5b11bc4bbab9e00de7c80ea2bbf4a9d797201
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
