vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookincubator/fizz
    REF v2021.10.11.00
    SHA512 9df2e90c4d1b72c6f0a4726b7f05ba806a24ed775e5703f937575a46643cc3bfd5d9571cdb07063f1f835675437d77e20685cc86322fdae25d0d5303f4e30b2a
    HEAD_REF master
    PATCHES
        fix-libsodium.patch
        fix-wangle.patch
)

# Prefer installed config files
file(REMOVE
    ${SOURCE_PATH}/fizz/cmake/FindGflags.cmake
    ${SOURCE_PATH}/fizz/cmake/FindGlog.cmake
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}/fizz"
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DINCLUDE_INSTALL_DIR:STRING=include
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/fizz)
vcpkg_copy_pdbs()

# Release fizz-targets.cmake does not link to the right libraries in debug mode.
# We substitute with generator expressions so that the right libraries are linked for debug and release.
set(FIZZ_TARGETS_CMAKE "${CURRENT_PACKAGES_DIR}/share/fizz/fizz-targets.cmake")
FILE(READ ${FIZZ_TARGETS_CMAKE} _contents)
STRING(REPLACE "\${_IMPORT_PREFIX}/lib/glog.lib" "glog::glog" _contents "${_contents}")
STRING(REPLACE "\${_IMPORT_PREFIX}/lib/" "\${_IMPORT_PREFIX}/\$<\$<CONFIG:DEBUG>:debug/>lib/" _contents "${_contents}")
STRING(REPLACE "\${_IMPORT_PREFIX}/debug/lib/" "\${_IMPORT_PREFIX}/\$<\$<CONFIG:DEBUG>:debug/>lib/" _contents "${_contents}")
STRING(REPLACE "-vc140-mt.lib" "-vc140-mt\$<\$<CONFIG:DEBUG>:-gd>.lib" _contents "${_contents}")
FILE(WRITE ${FIZZ_TARGETS_CMAKE} "${_contents}")
FILE(READ ${CURRENT_PACKAGES_DIR}/share/fizz/fizz-config.cmake _contents)
FILE(WRITE ${CURRENT_PACKAGES_DIR}/share/fizz/fizz-config.cmake
"include(CMakeFindDependencyMacro)
find_dependency(Threads)
find_dependency(glog CONFIG)
find_dependency(gflags CONFIG REQUIRED)
find_dependency(ZLIB)
${_contents}")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/fizz/fizz-config.cmake" "lib/cmake/fizz" "share/fizz")

file(REMOVE_RECURSE
${CURRENT_PACKAGES_DIR}/debug/include
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/fizz/tool/test" "${CURRENT_PACKAGES_DIR}/include/fizz/util/test")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)