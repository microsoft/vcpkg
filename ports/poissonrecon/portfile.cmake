vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mkazhdan/PoissonRecon
    REF 03f73754e994eb388de63285d3a2772493168e8a
    SHA512 be1d6842952d2b27860b5a82d9cc536da213fd2e44d946c512e04881af66a4c7c039930347fe9db5b168cc356e55167c9bdbdb39eab9cea68882dc01a9482867
    HEAD_REF master
    PATCHES
        use-external-libs.patch
        disable-gcc5-checks.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TOOLS=OFF
)

file(WRITE "${CURRENT_PACKAGES_DIR}/share/poissonrecon/PoissonRecon-config.cmake" [=[
include(CMakeFindDependencyMacro)
find_dependency(PNG)
find_dependency(JPEG)
include("${CMAKE_CURRENT_LIST_DIR}/PoissonReconTargets.cmake")
]=])

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
