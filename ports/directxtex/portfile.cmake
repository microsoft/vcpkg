vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "OSX")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF apr2021
    SHA512 0f2624d7ca6f30e75e5a394c3f4730b068dac256f3571df024d5421f2ce777ee1bf3d90984e93d4ed881d2364dc7bd0dc6b2b48c0abe50a5bc5c2071ce2ba711
    HEAD_REF master
)

if("openexr" IN_LIST FEATURES)
    vcpkg_download_distfile(
        DIRECTXTEX_EXR_HEADER
        URLS "https://raw.githubusercontent.com/wiki/Microsoft/DirectXTex/DirectXTexEXR.h"
        FILENAME "DirectXTexEXR-2.h"
        SHA512 54163820996f7f3c47d0e34da7d717ba51a4363458d77e8f3750d2b6b38bcf803f199b913b4fd7b8dcdd3f520cd0c2bb42a9f79d30f5805fccdece6af368dd12
    )

    vcpkg_download_distfile(
        DIRECTXTEX_EXR_SOURCE
        URLS "https://raw.githubusercontent.com/wiki/Microsoft/DirectXTex/DirectXTexEXR.cpp"
        FILENAME "DirectXTexEXR-2.cpp"
        SHA512 fbf5a330961f3ac80e4425e8451e9a696240cd89fabca744a19f1f110ae188bae7d8eb5b058aaf66015066d919d4f581b14494d78d280147b23355d8a32745b9
    )

    file(COPY ${DIRECTXTEX_EXR_HEADER} DESTINATION ${SOURCE_PATH}/DirectXTex)
    file(COPY ${DIRECTXTEX_EXR_SOURCE} DESTINATION ${SOURCE_PATH}/DirectXTex)
    file(RENAME ${SOURCE_PATH}/DirectXTex/DirectXTexEXR-2.h ${SOURCE_PATH}/DirectXTex/DirectXTexEXR.h)
    file(RENAME ${SOURCE_PATH}/DirectXTex/DirectXTexEXR-2.cpp ${SOURCE_PATH}/DirectXTex/DirectXTexEXR.cpp)
    vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH} PATCHES enable_openexr_support.patch)
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dx12 BUILD_DX12
        openexr ENABLE_OPENEXR_SUPPORT
)

if (VCPKG_HOST_IS_LINUX)
    message(WARNING "Build ${PORT} requires GCC version 9 or later")
endif()

if(VCPKG_TARGET_IS_UWP)
  set(EXTRA_OPTIONS -DBUILD_TOOLS=OFF)
else()
  set(EXTRA_OPTIONS -DBUILD_TOOLS=ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        ${EXTRA_OPTIONS}
        -DBC_USE_OPENMP=ON
        -DBUILD_DX11=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

if((VCPKG_HOST_IS_WINDOWS) AND (VCPKG_TARGET_ARCHITECTURE MATCHES x64) AND (NOT ("openexr" IN_LIST FEATURES)))
  vcpkg_download_distfile(
    TEXASSEMBLE_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/apr2021/texassemble.exe"
    FILENAME "texassemble-apr2021.exe"
    SHA512 1ab77d057d859600cd74632cd236b4ba619ec3538fae2871488bfbe3434bf1acb3ea594b034d5bc7e631954f83e5170b2edb9bc9f228e9216771762ed971a4a2
  )

  vcpkg_download_distfile(
    TEXCONV_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/apr2021/texconv.exe"
    FILENAME "texconv-apr2021.exe"
    SHA512 6e4f0b775097cd45b54b9b024b6e2f7783d7b3af8cf0e120fb01d69318b30857506260be35b571e873300403acec3c325be6357d05a1fa5971c14ce3065343bc
  )

  vcpkg_download_distfile(
    TEXDIAG_EXE
    URLS "https://github.com/Microsoft/DirectXTex/releases/download/apr2021/texdiag.exe"
    FILENAME "texdiag-apr2021.exe"
    SHA512 f35b2719d47ed36159a7572b632da26179db8d6b2a0164cd6cf917e5220ff04e6179987ca605d8d534cbc76fc8c5204c87748ed5be3dfb393413d5e1e7a58895
  )

  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxtex/")

  file(INSTALL
    ${TEXASSEMBLE_EXE}
    ${TEXCONV_EXE}
    ${TEXDIAG_EXE}
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxtex/)

  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble-apr2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtex/texassemble.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv-apr2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtex/texconv.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/tools/directxtex/texdiag-apr2021.exe ${CURRENT_PACKAGES_DIR}/tools/directxtex/texadiag.exe)

elseif((VCPKG_TARGET_IS_WINDOWS) AND (NOT VCPKG_TARGET_IS_UWP))

  vcpkg_copy_tools(
        TOOL_NAMES texassemble texconv texdiag
        SEARCH_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/CMake
    )

endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
