vcpkg_fail_port_install(ON_ARCH "x86" "arm" ON_TARGET "UWP" "LINUX" "ANDROID" "FREEBSD" "OSX")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(VERSION 2.3.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-gpu-windows-x86_64-2.3.0.zip"
    FILENAME "libtensorflow-gpu-windows-x86_64-2.3.0.zip"
    SHA512 2e81ca1f890ec3334a227a14a749564ca618550e704363e69af807ac24c1a8be0c45893d7ce5320455a62aa9e775fa2e4f6e3afc3178019f5f9f34e527401666
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
    REF ${VERSION}
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
        DESTINATION ${CURRENT_PACKAGES_DIR}
    )

file(COPY ${SOURCE_PATH}/lib/tensorflow.lib 
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/lib/tensorflow.lib 
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY ${SOURCE_PATH}/lib/tensorflow.dll 
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/lib/tensorflow.dll 
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
