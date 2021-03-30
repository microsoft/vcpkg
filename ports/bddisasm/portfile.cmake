vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ianichitei/bddisasm
    REF cc6cf1e2b6259e80c82877bcfe7051485588f905
    SHA512 122790cc8763497302971ad00e22e71a04ceeeeaa06bb8c009fb2b5885909470925e2b7fe68aca93b7d92ec3cdacb1e164670f2ee5b1e27b0c48d1278df1b8b1
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS -DBDD_INCLUDE_TOOL=OFF
)

vcpkg_install_cmake()

file(INSTALL
    ${CURRENT_PORT_DIR}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/bddisasm TARGET_PATH share/bddisasm)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH bddisasm/bddisasm.vcxproj
        USE_VCPKG_INTEGRATION
    )

    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH bdshemu/bdshemu.vcxproj
        USE_VCPKG_INTEGRATION
    )

    file(COPY ${SOURCE_PATH}/inc/
        DESTINATION ${CURRENT_PACKAGES_DIR}/include/bddisasm
        FILES_MATCHING PATTERN *.h
    )

    # disasmtool.exe will be placed here, but it shouldn't. We can't delete only disasmtool.exe because that will
    # leave us with two empty directories, and that's an error.
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/" "${CURRENT_PACKAGES_DIR}/debug/bin/")
endif ()
