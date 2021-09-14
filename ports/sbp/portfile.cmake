# Windows shared libraries are not supported yet
# See https://github.com/swift-nav/libsbp/issues/1062
vcpkg_fail_port_install(ON_TARGET "uwp")

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO swift-nav/libsbp
    REF v3.4.10
    SHA512 bbdcefad9ff8995759b577790bcffb94355bd0ee29f259fa8d51f54907e252b55871dc5a841e21d23e661fd5b33109761eb20b66c2fb73e9e7de8a34cc8d6528
    HEAD_REF master
    PATCHES
      "win32-install-fix.patch"
)

vcpkg_from_github(
    OUT_SOURCE_PATH CMAKE_EXTRA_MODS
    REPO swift-nav/cmake
    REF 373d4fcafbbc0c208dc9ecb278d36ed8c9448eda
    SHA512 afefc8c7a3fb43ee65b9b8733968a5836938460abbf1bc9e8330f83c3ac4a5819f71a36dcb034004296161c592f4d61545ba10016d6666e7eaf1dca556d99e2e
    HEAD_REF master
)

# Copy cmake files to expected location
file(INSTALL "${CMAKE_EXTRA_MODS}/CCache.cmake" DESTINATION "${SOURCE_PATH}/c/cmake/common")
file(INSTALL "${CMAKE_EXTRA_MODS}/SwiftCmakeOptions.cmake" DESTINATION "${SOURCE_PATH}/c/cmake/common")
file(INSTALL "${CMAKE_EXTRA_MODS}/CompileOptions.cmake" DESTINATION "${SOURCE_PATH}/c/cmake/common")
file(INSTALL "${CMAKE_EXTRA_MODS}/LanguageStandards.cmake" DESTINATION "${SOURCE_PATH}/c/cmake/common")
file(INSTALL "${CMAKE_EXTRA_MODS}/ClangFormat.cmake" DESTINATION "${SOURCE_PATH}/c/cmake/common")
file(INSTALL "${CMAKE_EXTRA_MODS}/ClangTidy.cmake" DESTINATION "${SOURCE_PATH}/c/cmake/common")
file(INSTALL "${CMAKE_EXTRA_MODS}/CodeCoverage.cmake" DESTINATION "${SOURCE_PATH}/c/cmake/common")
file(INSTALL "${CMAKE_EXTRA_MODS}/TestTargets.cmake" DESTINATION "${SOURCE_PATH}/c/cmake/common")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/c"
    OPTIONS
      -Dlibsbp_ENABLE_TESTS=OFF
      -Dlibsbp_ENABLE_DOCS=OFF
)

vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
