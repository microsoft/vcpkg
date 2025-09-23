# Prefer using the local repository root when testing with --overlay-ports.
# If the local source is not available, fall back to downloading from GitHub tag v2.1.1.
# PORT_DIR is .../contrib/vcpkg/ports/uniconv, go up four levels to reach repo root
set(LOCAL_SRC "${PORT_DIR}/../../../..")
if(EXISTS "${LOCAL_SRC}/CMakeLists.txt")
    message(STATUS "uniconv: using local source at ${LOCAL_SRC}")
    set(SOURCE_PATH "${LOCAL_SRC}")
else()
    message(STATUS "uniconv: local source not found, fetching from GitHub tag v2.1.1")
    # Use commit SHA for REF, and tag name for FETCH_REF
    vcpkg_from_git(
        OUT_SOURCE_PATH SOURCE_PATH
        URL "https://github.com/hesphoros/UniConv.git"
        REF "e8efa5bafd43827970f292eaab551d36185d1dd0"
        FETCH_REF "v2.1.1"
        # For PRs it's preferable to replace REF with the release tag and include a verified SHA
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUNICONV_BUILD_TESTS=OFF
)

vcpkg_install_cmake()

# 合并和修正 CMake config 路径
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/UniConv)

# 清理 debug/include 和 debug/share
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# 安装 LICENSE 到 copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# vcpkg policy: 允许 debug/include、debug/share、lib/cmake 合并
set(VCPKG_POLICY_ALLOW_DEBUG_INCLUDE enabled)
set(VCPKG_POLICY_ALLOW_DEBUG_SHARE enabled)
set(VCPKG_POLICY_SKIP_MISPLACED_CMAKE_FILES_CHECK enabled)
set(VCPKG_POLICY_SKIP_LIB_CMAKE_MERGE_CHECK enabled)
set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled)
