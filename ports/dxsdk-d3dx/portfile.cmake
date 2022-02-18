if(EXISTS "${CURRENT_INSTALLED_DIR}/share/directxsdk/copyright")
    message(FATAL_ERROR "Can't build ${PORT} if directxsdk is installed. Please remove directxsdk, and try to install ${PORT} again if you need it.")
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

file(GLOB HEADER_FILES "${PACKAGE_PATH}/build/native/include/*.h" "${PACKAGE_PATH}/build/native/include/*.inl")
file(INSTALL ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

file(GLOB RELEASE_LIB_FILES "${PACKAGE_PATH}/build/native/release/lib/${VCPKG_TARGET_ARCHITECTURE}/*.lib")
file(INSTALL ${RELEASE_LIB_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/lib/")

file(GLOB DEBUG_LIB_FILES "${PACKAGE_PATH}/build/native/debug/lib/${VCPKG_TARGET_ARCHITECTURE}/*.lib")
file(INSTALL ${DEBUG_LIB_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/")

file(GLOB RELEASE_DLL_FILES "${PACKAGE_PATH}/build/native/release/bin/${VCPKG_TARGET_ARCHITECTURE}/*.dll")
file(INSTALL ${RELEASE_DLL_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/bin/")

file(GLOB DEBUG_DLL_FILES "${PACKAGE_PATH}/build/native/debug/bin/${VCPKG_TARGET_ARCHITECTURE}/*.dll")
file(INSTALL ${DEBUG_DLL_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin/")

file(INSTALL "${PACKAGE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
