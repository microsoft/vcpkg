# Windows shared libraries are not supported yet
# PR has been already merged to upstream, but there is still some issue.
# See https://github.com/swift-nav/libsbp/issues/1062
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO swift-nav/libsbp
    REF "v${VERSION}"
    SHA512 1c56338e2d8a459becc9acd29470d1d473680c0930b10f1fcc46760cd0b4614613fff76a5b23d0d889be39c3da7219837d9944310f6ed893191c171d050a7a88
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH CMAKE_EXTRA_MODS
    REPO swift-nav/cmake
    REF d5558e3ad3c2cdabfb1ba31d20ea4defce570a95
    SHA512 50c49b808b774c3fec1dd4488713f8fde423fda1d7e34a9ea8ecabc738d19f31ce8d52928c9d8012921d69130526ebd327635b1d4ca43f1b452066191c8756b7
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

vcpkg_cmake_config_fixup(CONFIG_PATH share/libsbp/cmake PACKAGE_NAME libsbp)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
