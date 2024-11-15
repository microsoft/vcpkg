set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

set(key NOTFOUND)
if(VCPKG_TARGET_IS_WINDOWS)
    set(key "Windows-${VCPKG_TARGET_ARCHITECTURE}")
else()
    set(key "${VCPKG_CMAKE_SYSTEM_NAME}-${VCPKG_TARGET_ARCHITECTURE}")
endif()

set(buf_exe NOTFOUND)
# For convenient updates, use
# vcpkg install vcpkg-tool-buf --cmake-args=-DVCPKG_BUF_UPDATE=1
if(key STREQUAL "Linux-x64" OR VCPKG_BUF_UPDATE)
    set(download_platform "Linux-x86_64")
    vcpkg_download_distfile(buf_exe
        URLS "https://github.com/bufbuild/buf/releases/download/v${VERSION}/buf-${download_platform}"
        FILENAME "buf-${VERSION}-${download_platform}"
        SHA512 3b1be1ba442e1bbcbfe46b8160332e5db243a6dc5c8847655066ef760a0941d8d78189f8d5df28f2ed7cec392bf7e363fad242645524b0bba6d75e88fb7d96c2
    )
endif()
if(key STREQUAL "Linux-arm64" OR VCPKG_BUF_UPDATE)
    set(download_platform "Linux-aarch64")
    vcpkg_download_distfile(buf_exe
        URLS "https://github.com/bufbuild/buf/releases/download/v${VERSION}/buf-${download_platform}"
        FILENAME "buf-${VERSION}-${download_platform}"
        SHA512 cc4b180e204b5ef77c129979de36a9e197d5011961e25b019891c715f0ef467d71317f8d9b75fa97df5c44b20d6448481bae9cea4d16a266d616bba558b9ccaf
    )
endif()
if(key STREQUAL "Windows-x64" OR VCPKG_BUF_UPDATE)
    set(download_platform "Windows-x86_64")
    vcpkg_download_distfile(buf_exe
        URLS "https://github.com/bufbuild/buf/releases/download/v${VERSION}/buf-${download_platform}.exe"
        FILENAME "buf-${VERSION}-${download_platform}.exe"
        SHA512 cac49c4ff5d7b68ec5780f8a56c639e6b755ea3a4358e7a90963eb3445eaa14c0483f08d45eb0e29c5d440b30ef2830c43c839ad47805d121e6080c97660581f
    )
endif()
if(key STREQUAL "Windows-arm64" OR VCPKG_BUF_UPDATE)
    set(download_platform "Windows-arm64")
    vcpkg_download_distfile(buf_exe
        URLS "https://github.com/bufbuild/buf/releases/download/v${VERSION}/buf-${download_platform}.exe"
        FILENAME "buf-${VERSION}-${download_platform}.exe"
        SHA512 cf207fb7efb0bef9e8f650f22c015a51f8ebc7dfb3e1182c32c00dfb772eefceb1ced0b6d86fec6eea6d64b08d07c1b15c371c08737d98cf3c31e8498c9cdcb0
    )
endif()
if(key STREQUAL "Darwin-x64" OR VCPKG_BUF_UPDATE)
    set(download_platform "Darwin-x86_64")
    vcpkg_download_distfile(buf_exe
        URLS "https://github.com/bufbuild/buf/releases/download/v${VERSION}/buf-${download_platform}"
        FILENAME "buf-${VERSION}-${download_platform}"
        SHA512 9b7ff943b32ea86c818063e52b785f315f6fba596199d1670f9b29331ede7db16646f4de092902238724f323cb99603ca1a05f6ee30c7f673148d2b09fa2a1ed
    )
endif()
if(key STREQUAL "Darwin-arm64" OR VCPKG_BUF_UPDATE)
    set(download_platform "Darwin-arm64")
    vcpkg_download_distfile(buf_exe
        URLS "https://github.com/bufbuild/buf/releases/download/v${VERSION}/buf-${download_platform}"
        FILENAME "buf-${VERSION}-${download_platform}"
        SHA512 8944bc4ee0597213a1209334ad2c0a012779f4cb1a009bc94355c391f1eae4ef668d7b20356591314282030c1db6c554dfbfed7494341c58703e3ff0e37b7c1b
    )
endif()
if(NOT buf_exe)
    message(FATAL_ERROR "Unsupported platform. Please implement me!")
endif()

vcpkg_download_distfile(buf_license
    URLS "https://raw.githubusercontent.com/bufbuild/buf/v${VERSION}/LICENSE"
    FILENAME "buf-${VERSION}-LICENSE"
    SHA512 b2826964a02434bd195b8fdcff1702684c4f2645ed6227ad37e7b5c96c5b434a93a8c0dac40f0c7eed55edb79f008dc8b2a46cdfa60e4e8c0a0512fd0fdf723f
)

if(VCPKG_BUF_UPDATE)
    message(STATUS "All downloads are up-to-date.")
    message(FATAL_ERROR "Stopping due to VCPKG_BUF_UPDATE being enabled.")
endif()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/buf")
file(INSTALL "${buf_exe}"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/buf"
    RENAME "buf${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
    FILE_PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE
)

vcpkg_install_copyright(FILE_LIST "${buf_license}")
