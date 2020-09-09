# Header-only library
vcpkg_download_distfile(D3DX12_H
    URLS "https://raw.githubusercontent.com/walbourn/directx-vs-templates/may2020/d3d12game_win32_dr/d3dx12.h"
    FILENAME "d3dx12.h"
    SHA512 "58a1f5060c82c2769987592d6f20d8c8d86032505740492b24f69c88b75f0814d3f18d5c3ae7c71c54bfe5eeb7f844ee623ce73376a676986db0643589aab62b"
)

file(INSTALL ${D3DX12_H} DESTINATION ${CURRENT_PACKAGES_DIR}/include/)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "")
