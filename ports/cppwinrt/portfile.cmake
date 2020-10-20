vcpkg_fail_port_install(ON_TARGET linux osx)

set(PACKAGE_NAME Microsoft.Windows.CppWinRT)
set(VERSION 2.0.201008.2)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)

vcpkg_find_acquire_program(NUGET)
vcpkg_execute_required_process(
    ALLOW_IN_DOWNLOAD_MODE
    COMMAND ${NUGET} install ${PACKAGE_NAME} -ExcludeVersion -Version ${VERSION} -NonInteractive -OutputDirectory "${SOURCE_PATH}"
    LOGNAME nuget-${TARGET_TRIPLET}
)

set(PACKAGE_PATH ${SOURCE_PATH}/${PACKAGE_NAME})

vcpkg_execute_required_process(
    COMMAND "${PACKAGE_PATH}/bin/cppwinrt.exe" -input sdk -output "${PACKAGE_PATH}/include"
)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${PACKAGE_PATH})
vcpkg_configure_cmake(
    SOURCE_PATH ${PACKAGE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(INSTALL ${PACKAGE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)