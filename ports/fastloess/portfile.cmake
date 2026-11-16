vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(FASTLOESS_HAS_DEBUG_PACKAGE OFF)

if(VCPKG_TARGET_IS_WINDOWS)
    # Rust's MSVC stdlib is built against the release CRT (/MD). Even the
    # upstream debug-c profile therefore links VCRUNTIME140.dll, not
    # VCRUNTIME140D.dll. Separate Debug/Release DLLs are still published
    # (optimization and debug info differ); skip the post-build CRT check
    # the same way ports/rerun-sdk does for its prebuilt Rust cdylib.
    set(VCPKG_POLICY_SKIP_CRT_LINKAGE_CHECK enabled)
    if(VCPKG_TARGET_IS_MINGW)
        message(
            FATAL_ERROR
            "fastloess prebuilt Windows archives require the MSVC ABI."
        )
    endif()
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(FASTLOESS_PLATFORM windows-x64-msvc)
        set(FASTLOESS_DEBUG_PLATFORM windows-x64-msvc-debug)
        set(FASTLOESS_BINARY_NAME fastloess-win32-x64.dll)
        set(FASTLOESS_DEBUG_BINARY_NAME fastloess-win32-x64-debug.dll)
        set(FASTLOESS_ARCHIVE_SHA512
            "977d055478f7a0f485f3248bbeb978d4e9aac1b01454241674c3bc74133f2f7bdc0e90ef2220900925d694acce78dc61ac62a56784f1ef218aaf12cc3936337e"
        )
        set(FASTLOESS_DEBUG_ARCHIVE_SHA512
            "6b4a7a101ff50ce48bc385afb5661f207313a5d3ccdd9b63e6df7726d833dbd9589e2cc58674757d64ba677c80c7df113ac482cfd3fb4d0f605d8cefa3d64339"
        )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FASTLOESS_PLATFORM windows-arm64)
        set(FASTLOESS_DEBUG_PLATFORM windows-arm64-debug)
        set(FASTLOESS_BINARY_NAME fastloess-win32-arm64.dll)
        set(FASTLOESS_DEBUG_BINARY_NAME fastloess-win32-arm64-debug.dll)
        set(FASTLOESS_ARCHIVE_SHA512
            "42ef050ba1b55c481eb599ee3656e845a80812fa3b74f40f466959266a12ccf25f26f897da1da6d1a5b7f8c8f1da57df3ce870ee70fc64e95fb346711fcb5e19"
        )
        set(FASTLOESS_DEBUG_ARCHIVE_SHA512
            "62a36d66409b4d0125cd1a60b0103d523878b25cf6b1bd9242fe9d06da48e44b944758522d18cbc65831fbebb181350be6cf3107f62c6a72135ea7a24741a937"
        )
    else()
        message(
            FATAL_ERROR
            "fastloess does not support Windows architecture ${VCPKG_TARGET_ARCHITECTURE}."
        )
    endif()
    set(FASTLOESS_HAS_DEBUG_PACKAGE ON)
    set(FASTLOESS_LIBRARY_DIR bin)
elseif(VCPKG_TARGET_IS_LINUX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(FASTLOESS_ARCH x64)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FASTLOESS_ARCH arm64)
    else()
        message(
            FATAL_ERROR
            "fastloess does not support Linux architecture ${VCPKG_TARGET_ARCHITECTURE}."
        )
    endif()
    set(FASTLOESS_PLATFORM "linux-${FASTLOESS_ARCH}")
    set(FASTLOESS_BINARY_NAME "libfastloess-linux-${FASTLOESS_ARCH}.so")
    set(FASTLOESS_LIBRARY_DIR lib)
    if(FASTLOESS_ARCH STREQUAL "x64")
        set(FASTLOESS_ARCHIVE_SHA512
            "e0c3ed211512229f9f9c6c3dbbcb59857feb006e24a63c29906f90fbced04c2dab08d8768c9ab909df70698e89cad3dd55717f73f6e1450228770cada0b5a531"
        )
    else()
        set(FASTLOESS_ARCHIVE_SHA512
            "980035968ea1b12713043f5734f7afead9098ce0a8378be8e5b1a9b99af13693877b94c6638c3ba6967935776a47ea82638ec55f671acab7b4f622a38181bbb1"
        )
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(FASTLOESS_ARCH x64)
        set(FASTLOESS_ARCHIVE_SHA512
            "572ec85fdf3f8c8073de73998f2bc1c8b753388dcb7aae1ff2a8349b1728f5bcf7182db1367c5d488bbd1c122b78cc82040f106b5226457a6d01f38e627d5009"
        )
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FASTLOESS_ARCH arm64)
        set(FASTLOESS_ARCHIVE_SHA512
            "96329d6e0446a7eaddd2460ac2a7ebeba2387c04a7906d6b6a234ba40489f142e4485b100882a597fe3b2465937f3b7e42b5f20c6a6d20ba496bc0834b94583f"
        )
    else()
        message(
            FATAL_ERROR
            "fastloess does not support macOS architecture ${VCPKG_TARGET_ARCHITECTURE}."
        )
    endif()
    set(FASTLOESS_PLATFORM "macos-${FASTLOESS_ARCH}")
    set(FASTLOESS_BINARY_NAME "libfastloess-macos-${FASTLOESS_ARCH}.dylib")
    set(FASTLOESS_LIBRARY_DIR lib)
else()
    message(FATAL_ERROR "fastloess does not support this target platform.")
endif()

vcpkg_download_distfile(
    FASTLOESS_ARCHIVE
    URLS "https://github.com/thisisamirv/loess-project/releases/download/v${VERSION}/libfastloess-${FASTLOESS_PLATFORM}.tar"
    FILENAME "fastloess-v${VERSION}/libfastloess-${FASTLOESS_PLATFORM}.tar"
    SHA512 "${FASTLOESS_ARCHIVE_SHA512}"
)
vcpkg_extract_source_archive(
    FASTLOESS_PACKAGE_DIR
    ARCHIVE "${FASTLOESS_ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

set(FASTLOESS_DEBUG_PACKAGE_DIR "")
if(FASTLOESS_HAS_DEBUG_PACKAGE)
    vcpkg_download_distfile(
        FASTLOESS_DEBUG_ARCHIVE
        URLS "https://github.com/thisisamirv/loess-project/releases/download/v${VERSION}/libfastloess-${FASTLOESS_DEBUG_PLATFORM}.tar"
        FILENAME "fastloess-v${VERSION}/libfastloess-${FASTLOESS_DEBUG_PLATFORM}.tar"
        SHA512 "${FASTLOESS_DEBUG_ARCHIVE_SHA512}"
    )
    vcpkg_extract_source_archive(
        FASTLOESS_DEBUG_PACKAGE_DIR
        ARCHIVE "${FASTLOESS_DEBUG_ARCHIVE}"
        NO_REMOVE_ONE_LEVEL
    )
endif()

if(VCPKG_TARGET_IS_OSX)
    vcpkg_execute_required_process(
        COMMAND
            install_name_tool
            -id
            "@rpath/${FASTLOESS_BINARY_NAME}"
            "${FASTLOESS_PACKAGE_DIR}/${FASTLOESS_BINARY_NAME}"
        WORKING_DIRECTORY "${FASTLOESS_PACKAGE_DIR}"
        LOGNAME "install-name-${FASTLOESS_PLATFORM}"
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thisisamirv/loess-project
    REF "v${VERSION}"
    SHA512 "0e3ab46e2f42267e4c82f88bcdb66dbdef2b2cf5e44fa5c7a826c3324f0c30610d00fd6193ff706576d885999d7b55c231a8e3698addfc9daa968a83b217e79c"
)

set(FASTLOESS_CMAKE_OPTIONS
    "-DFASTLOESS_VERSION=${VERSION}"
    "-DFASTLOESS_PACKAGE_DIR=${FASTLOESS_PACKAGE_DIR}"
    "-DFASTLOESS_BINARY_NAME=${FASTLOESS_BINARY_NAME}"
    "-DFASTLOESS_LIBRARY_DIR=${FASTLOESS_LIBRARY_DIR}"
)
if(FASTLOESS_HAS_DEBUG_PACKAGE)
    list(
        APPEND FASTLOESS_CMAKE_OPTIONS
        "-DFASTLOESS_DEBUG_PACKAGE_DIR=${FASTLOESS_DEBUG_PACKAGE_DIR}"
        "-DFASTLOESS_DEBUG_BINARY_NAME=${FASTLOESS_DEBUG_BINARY_NAME}"
    )
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    list(
        APPEND FASTLOESS_CMAKE_OPTIONS
        "-DFASTLOESS_ARCH=${VCPKG_TARGET_ARCHITECTURE}"
    )
endif()
vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}"
    OPTIONS ${FASTLOESS_CMAKE_OPTIONS}
)
vcpkg_cmake_install()
file(
    REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE-MIT" "${SOURCE_PATH}/LICENSE-APACHE"
)
file(
    INSTALL "${CURRENT_PORT_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
