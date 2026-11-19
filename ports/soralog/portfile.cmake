vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xDimon/soralog
    REF "v${VERSION}"
    SHA512 ec28d5ea33cae303b295c2bfe189da6e135673d1c9859acf5d68f7a8b171a25c2a9a667f0694ae687a7b681d10a18b08b009b5651378547f13969576630bdadb
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_BENCHMARK_COMPARE=OFF
        -DEXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

# Upstream installs the export set itself as soralogConfig.cmake, which does
# not look up the dependencies; wrap it into a config that does.
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/soralogConfig.cmake"
            "${CURRENT_PACKAGES_DIR}/share/${PORT}/soralogTargets.cmake")
file(GLOB _soralog_target_files "${CURRENT_PACKAGES_DIR}/share/${PORT}/soralogConfig-*.cmake")
foreach(_file IN LISTS _soralog_target_files)
    string(REPLACE "soralogConfig-" "soralogTargets-" _new_file "${_file}")
    file(RENAME "${_file}" "${_new_file}")
endforeach()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/soralogTargets.cmake"
    "/soralogConfig-*.cmake"
    "/soralogTargets-*.cmake"
)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/soralogConfig.cmake" [[
include(CMakeFindDependencyMacro)
find_dependency(fmt CONFIG)
find_dependency(yaml-cpp CONFIG)
include("${CMAKE_CURRENT_LIST_DIR}/soralogTargets.cmake")
]])

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
