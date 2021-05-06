vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP")

if(NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "${PORT} only supports Windows.")
endif()

message(WARNING "Use of ${PORT} is not recommended for new projects. See https://aka.ms/dxsdk for more information.")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(VCPKG_POLICY_ALLOW_OBSOLETE_MSVCRT enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.DXSDK.D3DX/9.29.952.8"
    FILENAME "dxsdk-d3dx.9.29.952.8.zip"
    SHA512 9f6a95ed858555c1c438a85219ede32c82729068b21dd7ecf11de01cf3cdd525b2f04a58643bfcc14c48a29403dc1c80246f0a12a1ef4377b91b855f6d6d7986
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(GLOB HEADER_FILES ${PACKAGE_PATH}/build/native/include/*.h ${PACKAGE_PATH}/build/native/include/*.inl)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

file(COPY ${PACKAGE_PATH}/build/native/release/lib/${VCPKG_TARGET_ARCHITECTURE}/d3dx9.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
file(COPY ${PACKAGE_PATH}/build/native/release/lib/${VCPKG_TARGET_ARCHITECTURE}/d3dx10.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
file(COPY ${PACKAGE_PATH}/build/native/release/lib/${VCPKG_TARGET_ARCHITECTURE}/d3dx11.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
file(COPY ${PACKAGE_PATH}/build/native/debug/lib/${VCPKG_TARGET_ARCHITECTURE}/d3dx9d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
file(COPY ${PACKAGE_PATH}/build/native/debug/lib/${VCPKG_TARGET_ARCHITECTURE}/d3dx10d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
file(COPY ${PACKAGE_PATH}/build/native/debug/lib/${VCPKG_TARGET_ARCHITECTURE}/d3dx11d.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)

file(COPY ${PACKAGE_PATH}/build/native/release/bin/${VCPKG_TARGET_ARCHITECTURE}/D3DCompiler_43.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin/)
file(COPY ${PACKAGE_PATH}/build/native/release/bin/${VCPKG_TARGET_ARCHITECTURE}/D3DX9_43.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin/)
file(COPY ${PACKAGE_PATH}/build/native/release/bin/${VCPKG_TARGET_ARCHITECTURE}/d3dx10_43.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin/)
file(COPY ${PACKAGE_PATH}/build/native/release/bin/${VCPKG_TARGET_ARCHITECTURE}/d3dx11_43.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin/)
file(COPY ${PACKAGE_PATH}/build/native/debug/bin/${VCPKG_TARGET_ARCHITECTURE}/D3DCompiler_43.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/)
file(COPY ${PACKAGE_PATH}/build/native/debug/bin/${VCPKG_TARGET_ARCHITECTURE}/D3DX9d_43.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/)
file(COPY ${PACKAGE_PATH}/build/native/debug/bin/${VCPKG_TARGET_ARCHITECTURE}/D3DX10d_43.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/)
file(COPY ${PACKAGE_PATH}/build/native/debug/bin/${VCPKG_TARGET_ARCHITECTURE}/D3DX11d_43.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/)

file(INSTALL ${PACKAGE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
