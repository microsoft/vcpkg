set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) # runtime only

vcpkg_download_distfile(BLOB_ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.Azure.Kinect.Sensor/${VERSION}"
    FILENAME "microsoft.azure.kinect.sensor.${VERSION}.nupkg.zip"
    SHA512 6e9e68f16bb00b3ddfdc963c6b62f9100d12b3407e0cd894052d5dc08ce2214e871f0c0977bff5b5e52af4ee325f775c818e2babacb6e8633b2887a9866c3ea3
)

vcpkg_extract_source_archive(
    PACKAGE_PATH
    ARCHIVE "${BLOB_ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

if(VCPKG_TARGET_IS_LINUX)
    file(COPY "${PACKAGE_PATH}/linux/lib/native/${VCPKG_TARGET_ARCHITECTURE}/release/libdepthengine.so.2.0" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    if(NOT VCPKG_BUILD_TYPE)
      file(COPY "${PACKAGE_PATH}/linux/lib/native/${VCPKG_TARGET_ARCHITECTURE}/release/libdepthengine.so.2.0" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
elseif(VCPKG_TARGET_IS_WINDOWS)
    string(REPLACE "x64" "amd64" ARCHITECTURE "${VCPKG_TARGET_ARCHITECTURE}")
    file(COPY "${PACKAGE_PATH}/lib/native/${ARCHITECTURE}/release/depthengine_2_0.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/azure-kinect-sensor-sdk")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/k4adeploy.ps1" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/azure-kinect-sensor-sdk")
    if(NOT VCPKG_BUILD_TYPE)
      file(COPY "${PACKAGE_PATH}/lib/native/${ARCHITECTURE}/release/depthengine_2_0.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools/azure-kinect-sensor-sdk")
      file(COPY "${CMAKE_CURRENT_LIST_DIR}/k4adeploy.ps1" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools/azure-kinect-sensor-sdk")
    endif()
endif()

vcpkg_install_copyright(FILE_LIST "${PACKAGE_PATH}/LICENSE.txt")
