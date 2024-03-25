set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

set(WINDOWS_APP_SDK_FILES
    "${CMAKE_CURRENT_LIST_DIR}/windowsappsdk.cmake"
    )

file(COPY ${WINDOWS_APP_SDK_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Use vcpkg's license
vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/LICENSE.txt")
