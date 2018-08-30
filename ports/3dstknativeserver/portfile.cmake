include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME OR NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR "3D Streaming Toolkit only works on Windows x64.")
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CatalystCode/3DStreamingToolkit
    REF v2.0
    SHA512 e0b5cc82b2061b4bf976e5d15342005a60dd671ba50d86a3094be028447dc1a66e46f4e26dba97a00781afc0257f0401378bbfd0f45dc447e428388f773d1b1a
    HEAD_REF master
)

# #Download various precompiled binaries
vcpkg_download_distfile(NVPIPEARCH
    URLS https://3dtoolkitstorage.blob.core.windows.net/libs/Nvpipe.zip
    FILENAME "3dstk-Nvpipe.zip"
    SHA512 b5fe6d1cf5bae83e50ee2c46f0b2e44433a418ec344390819d8b3d1b6a8f32100efb6984d31ea1c88e66f0247d99963d9744e359e93ff0b91e26d8d826285c4c
)

vcpkg_extract_source_archive(${NVPIPEARCH} ${SOURCE_PATH}/Libraries/Nvpipe)

vcpkg_download_distfile(M62HEADERS
    URLS https://3dtoolkitstorage.blob.core.windows.net/libs/m62patch_nvpipe_headers.zip
    FILENAME "3dstk-m62patch_nvpipe_headers.zip"
    SHA512 c23a47a76bbb1f92dea4c01d866aebbabe51160ee29a6c323542beb8f5430a152ee13f8fb0b48d985be09d58a8864d40f2672a6a2c0870cad0965f99b4abac26
)

vcpkg_extract_source_archive(${M62HEADERS} ${SOURCE_PATH}/Libraries/WebRTC)

vcpkg_download_distfile(M62PATCH64
    URLS https://3dtoolkitstorage.blob.core.windows.net/libs/m62patch_nvpipe_x64.zip
    FILENAME "3dstk-m62patch_nvpipe_x64.zip"
    SHA512 eb435ce963661ddbe366d4ba0cbc1cec33ab89d612443b42c8ac0b1b3d1a381d9c50e9ebcda6bc72e81bd028cb6d79376a592be6ae428e55afa453548effa29e
)

vcpkg_extract_source_archive(${M62PATCH64} ${SOURCE_PATH}/Libraries/WebRTC)

vcpkg_download_distfile(M62PATCH32
    URLS https://3dtoolkitstorage.blob.core.windows.net/libs/m62patch_nvpipe_Win32.zip
    FILENAME "3dstk-m62patch_nvpipe_Win32.zip"
    SHA512 aeb8ba3c914929800090c3d28bd147047cdb5fc6cde8b280d53a3c3219ec634cf1f97a296feb002531d6cdb869ef5236146b1c0a9a55aa46d1abd3eaa15045f5
)

vcpkg_extract_source_archive(${M62PATCH32} ${SOURCE_PATH}/Libraries/WebRTC)

vcpkg_download_distfile(LIBDIRECTX
    URLS https://3dtoolkitstorage.blob.core.windows.net/libs/libDirectXTK.zip
    FILENAME "3dstk-libDirectXTK.zip"
    SHA512 b7b9783b69d2489f06ea28c8266517194ecb5c7cd96eb770f1b4ab3bd9b5f720265b3dc296ddfd636de477ada4bff7247a069f8610a4f33f6569713142fc0f61
)

vcpkg_extract_source_archive(${LIBDIRECTX} ${SOURCE_PATH}/Libraries/DirectXTK)

vcpkg_download_distfile(WEBRTCM62
    URLS https://3dtoolkitstorage.blob.core.windows.net/libs/Org.WebRtc_m62_timestamp_v1.zip
    FILENAME "3dstk-Org.WebRtc_m62_timestamp_v1.zip"
    SHA512 01352b306a109bcc6111154e1d3741455c9cae40f745a07e404aef260a3135f08dbe52ae031aaafd40b43c3ee2c761e28a0f094b779d10bc8ce4b9fcf08d06a2
)

vcpkg_extract_source_archive(${WEBRTCM62} ${SOURCE_PATH}/Libraries/WebRTCUWP/Org.WebRtc)

vcpkg_download_distfile(LIBYUV
    URLS https://3dtoolkitstorage.blob.core.windows.net/libs/libyuv.zip
    FILENAME "3dstk-libyuv.zip"
    SHA512 d2fe45d8d600cd130d84aa3475ec34ebdb5c407d37027a04299cb0ede6f95323d8022c5dc2c8fb9781f3d0b103878c803e574810164a0b7dfbdc1044414bbdd0
)

vcpkg_extract_source_archive(${LIBYUV} ${SOURCE_PATH}/Libraries/WebRTCUWP/libyuv)

vcpkg_download_distfile(LIBOPENGL
    URLS https://3dtoolkitstorage.blob.core.windows.net/libs/libOpenGL.zip
    FILENAME "3dstk-libOpenGL.zip"
    SHA512 1e2591f35e56ff6aa923f45b404c3fa934a57ae114a207a3a82dbb3f12e850072d00d659b0b814a67ffebea1629950a7de5cb0d00144d6b68a606af59d0c022c
)

vcpkg_extract_source_archive(${LIBOPENGL} ${SOURCE_PATH}/Libraries)

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH Plugins/NativeServerPlugin/StreamingNativeServerPlugin.sln
    INCLUDES_SUBPATH Plugins/NativeServerPlugin/inc
    LICENSE_SUBPATH LICENSE
)

vcpkg_copy_pdbs()
