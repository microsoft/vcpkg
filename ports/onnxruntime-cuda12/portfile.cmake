vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if(VCPKG_TARGET_IS_WINDOWS)
    set(ORG_TARGET_OS win)
    set(ORG_ARCHIVE_EXT ".zip")
elseif(VCPKG_TARGET_IS_LINUX)
    set(ORG_TARGET_OS linux)
    set(ORG_ARCHIVE_EXT ".tgz")
else()
    message(FATAL_ERROR "onnxruntime-cuda12 only support windows and linux")
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ORG_TARGET_ARCH x64)
else()
    message(FATAL_ERROR "onnxruntime-cuda12 only support x64")
endif()

if(ORG_TARGET_OS STREQUAL "win")
    if(ORG_TARGET_ARCH STREQUAL "x64")
        set(ORG_ARCHIVE_SHA "81fbcb2ca5f245ee320af83ebdd3a5505a23e44d6bd32c47af00972a224ed0d410eef16f592bc9616943443361547128f8ffd8edf3a076708908004aef6225a4")
    endif()
elseif(ORG_TARGET_OS STREQUAL "linux")
    if(ORG_TARGET_ARCH STREQUAL "x64")
        set(ORG_ARCHIVE_SHA "3f610489a25abecaf9e53b903ed1e84215bbf57a2cb46b88ab5434dd8a63caf5b168b4c0646b0b81a78ea574301ebcbd9b32fd6641844ca2b374c36485f6d098")
    endif()
endif()

set(ORG_ARCHIVE_FILE_NAME "onnxruntime-${ORG_TARGET_OS}-${ORG_TARGET_ARCH}-gpu-cuda12-${VERSION}")
set(ORG_ARCHIVE_ROOT_DIR_NAME "onnxruntime-${ORG_TARGET_OS}-${ORG_TARGET_ARCH}-gpu-${VERSION}")

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/microsoft/onnxruntime/releases/download/v${VERSION}/${ORG_ARCHIVE_FILE_NAME}${ORG_ARCHIVE_EXT}"
    FILENAME "${ORG_ARCHIVE_FILE_NAME}${ORG_ARCHIVE_EXT}"
    SHA512 "${ORG_ARCHIVE_SHA}"
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

file(MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/include
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/debug/lib
)

file(COPY
    ${SOURCE_PATH}/${ORG_ARCHIVE_ROOT_DIR_NAME}/include
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(RENAME "${CURRENT_PACKAGES_DIR}/include/include" "${CURRENT_PACKAGES_DIR}/include/onnxruntime")

vcpkg_download_distfile(
    ORT_EXPERIMENTAL_HEADER_API
    URLS https://raw.githubusercontent.com/microsoft/onnxruntime/v${VERSION}/include/onnxruntime/core/session/experimental_onnxruntime_cxx_api.h
    FILENAME experimental_onnxruntime_cxx_api.h
    SHA512 6e62d96b2da12cf92e531296d10982ff0cd62f0b4c67c53aeaee0961122d6965f43139727ed89f89a476c568a99cececb46529513e721223abb1936781d5d0be
)
vcpkg_download_distfile(
    ORT_EXPERIMENTAL_HEADER_INLINE
    URLS https://raw.githubusercontent.com/microsoft/onnxruntime/v${VERSION}/include/onnxruntime/core/session/experimental_onnxruntime_cxx_inline.h
    FILENAME experimental_onnxruntime_cxx_inline.h
    SHA512 f158e6c04310d9cb66ddc32b555d61351d3aeeb43631f22124bbad1a115e9fda80832b134f59e4fa5482f5451021adcc616a28aee5fb52871757d2621c2d8d7d
)
file(COPY "${ORT_EXPERIMENTAL_HEADER_API}" DESTINATION "${CURRENT_PACKAGES_DIR}/include/onnxruntime/")
file(COPY "${ORT_EXPERIMENTAL_HEADER_INLINE}" DESTINATION "${CURRENT_PACKAGES_DIR}/include/onnxruntime/")

if(ORG_TARGET_OS STREQUAL "win")
    file(MAKE_DIRECTORY
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin
    )
endif()

file(GLOB ORT_LIB_FILES "${SOURCE_PATH}/${ORG_ARCHIVE_ROOT_DIR_NAME}/lib/*.lib" "${SOURCE_PATH}/${ORG_ARCHIVE_ROOT_DIR_NAME}/lib/*.so" "${SOURCE_PATH}/${ORG_ARCHIVE_ROOT_DIR_NAME}/lib/*.so.*")
file(GLOB ORT_BIN_FILES "${SOURCE_PATH}/${ORG_ARCHIVE_ROOT_DIR_NAME}/lib/*.pdb" "${SOURCE_PATH}/${ORG_ARCHIVE_ROOT_DIR_NAME}/lib/*.dll")

foreach(FILE IN LISTS ORT_LIB_FILES)
    file(COPY "${FILE}" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY "${FILE}" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endforeach()

foreach(FILE IN LISTS ORT_BIN_FILES)
    file(COPY "${FILE}" DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY "${FILE}" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endforeach()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/onnxruntime-cuda12-base-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
if(ORG_TARGET_OS STREQUAL "win")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/onnxruntime-cuda12-win-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/onnxruntime-cuda12-win-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/onnxruntime-cuda12-config.cmake")
else()
    configure_file("${CMAKE_CURRENT_LIST_DIR}/onnxruntime-cuda12-linux-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/onnxruntime-cuda12-config.cmake" IMMEDIATE @ONLY)
endif()


vcpkg_fixup_pkgconfig()

# # Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/${ORG_ARCHIVE_ROOT_DIR_NAME}/LICENSE")
