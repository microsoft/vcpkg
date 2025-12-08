vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xhk/nggmsg
    REF version-20251208-2
    SHA512 384595ce38dc6834e3a12e4f59b8c49512fe4005f2db906329a3e42512ade1d64e68f428303a5892ad0fba94d29433bc6bd60c00a2224df22fcfb63971ebf385
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

# 清理debug目录
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# 安装usage文件
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# 清理空目录
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib" "${CURRENT_PACKAGES_DIR}/lib")

# 安装版权文件
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# 禁用特定策略警告
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)
set(VCPKG_POLICY_ALLOW_EMPTY_FOLDERS enabled)