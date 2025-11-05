# Windows shared libraries are not supported yet
# See https://github.com/swift-nav/libsbp/issues/1062
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO swift-nav/libsbp
    REF "v${VERSION}"
    SHA512 2fb5daead688501280fae24fda62e58a4769f04006554faaef91cb1b8340adb9f1cc5e57e7ad13f8ca24bb538f1f3ec2d228cd17bba0c246a57075c671866ccd
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH CMAKE_EXTRA_MODS
    REPO swift-nav/cmake
    REF 65c9a396568701c382ca5a5515e6bb598f7d61b2
    SHA512 e8b1b1e48c7f6d71b156668ba6e0c0898d6a9b6c9e86bc63cb2b5a4cffa844a0a9a175699db8417bcb70bc4c6b278d32327f5c709e7db7b69ab2a81e7c398b23
    HEAD_REF master
)

# Copy cmake files to expected location
file(INSTALL "${CMAKE_EXTRA_MODS}/CCache.cmake" DESTINATION "${SOURCE_PATH}/c/cmake/common")
file(INSTALL "${CMAKE_EXTRA_MODS}/SwiftCmakeOptions.cmake" DESTINATION "${SOURCE_PATH}/c/cmake/common")
file(INSTALL "${CMAKE_EXTRA_MODS}/SwiftTargets.cmake" DESTINATION "${SOURCE_PATH}/c/cmake/common")
file(INSTALL "${CMAKE_EXTRA_MODS}/ListTargets.cmake" DESTINATION "${SOURCE_PATH}/c/cmake/common")
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
