vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mkazhdan/PoissonRecon
    REF 455ea0dbe651f31bf6985ff2891becff1dd79c72
    SHA512 93ef904b0a73b7650e2f1ed143444861661db74b4991182ffd0ff49c008fec9d664fb93e24825fce748576d8d6abbd1de8bfc8f8b1f7c48f57207712bf80ce9e
    HEAD_REF master
    PATCHES
        use-external-libs.patch
        disable-gcc5-checks.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TOOLS=OFF
)

file(WRITE "${CURRENT_PACKAGES_DIR}/share/poissonrecon/PoissonRecon-config.cmake" [=[
include(CMakeFindDependencyMacro)
find_dependency(PNG)
find_dependency(JPEG)
include("${CMAKE_CURRENT_LIST_DIR}/PoissonReconTargets.cmake")
]=])

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
