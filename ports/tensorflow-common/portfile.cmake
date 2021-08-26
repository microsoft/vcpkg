set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

set(TENSORFLOW_FILES
    "${CMAKE_CURRENT_LIST_DIR}/change-macros-for-static-lib.patch"
    "${CMAKE_CURRENT_LIST_DIR}/convert_lib_params_linux.py"
    "${CMAKE_CURRENT_LIST_DIR}/convert_lib_params_windows.py"
    "${CMAKE_CURRENT_LIST_DIR}/fix-build-error.patch"
    "${CMAKE_CURRENT_LIST_DIR}/fix-linux-build.patch"
    "${CMAKE_CURRENT_LIST_DIR}/fix-windows-build.patch"
    "${CMAKE_CURRENT_LIST_DIR}/generate_static_link_cmd_linux.py"
    "${CMAKE_CURRENT_LIST_DIR}/generate_static_link_cmd_macos.py"
    "${CMAKE_CURRENT_LIST_DIR}/generate_static_link_cmd_windows.py"
    "${CMAKE_CURRENT_LIST_DIR}/README-linux"
    "${CMAKE_CURRENT_LIST_DIR}/README-macos"
    "${CMAKE_CURRENT_LIST_DIR}/README-windows"
    "${CMAKE_CURRENT_LIST_DIR}/tensorflow-common.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/tensorflow-config-shared.cmake.in"
    "${CMAKE_CURRENT_LIST_DIR}/tensorflow-config-static.cmake.in"
    "${CMAKE_CURRENT_LIST_DIR}/tensorflow-config-windows-dll.cmake.in"
    "${CMAKE_CURRENT_LIST_DIR}/tensorflow-config-windows-lib.cmake.in"
    "${CMAKE_CURRENT_LIST_DIR}/Update-bazel-max-version.patch"
    )

file(COPY ${TENSORFLOW_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Use vcpkg's license
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
