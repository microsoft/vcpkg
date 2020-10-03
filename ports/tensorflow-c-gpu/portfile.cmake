# # Specifies if the port install should fail immediately given a condition
vcpkg_fail_port_install(MESSAGE "tensorflowcapigpu currently only supports Windows platforms" ON_TARGET "Linux")
vcpkg_fail_port_install(MESSAGE "tensorflowcapigpu currently only supports Windows platforms" ON_TARGET "Mac")

vcpkg_download_distfile(ARCHIVE
    URLS "https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-gpu-windows-x86_64-2.3.0.zip"
    FILENAME "libtensorflow-gpu-windows-x86_64-2.3.0.zip"
    SHA512 2e81ca1f890ec3334a227a14a749564ca618550e704363e69af807ac24c1a8be0c45893d7ce5320455a62aa9e775fa2e4f6e3afc3178019f5f9f34e527401666
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(MAKE_DIRECTORY
        ${CURRENT_PACKAGES_DIR}/include
        ${CURRENT_PACKAGES_DIR}/lib
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/lib
        ${CURRENT_PACKAGES_DIR}/debug/bin
    )

file(COPY 
        ${SOURCE_PATH}/include 
        DESTINATION ${CURRENT_PACKAGES_DIR}/include
    )

if (TRIPLET_SYSTEM_ARCH MATCHES "x64")
    file(COPY ${SOURCE_PATH}/lib/tensorflow.lib 
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${SOURCE_PATH}/lib/tensorflow.lib 
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(COPY ${SOURCE_PATH}/lib/tensorflow.dll 
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY ${SOURCE_PATH}/lib/tensorflow.dll 
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
