# Header-only library
vcpkg_download_distfile(D3DX12_H
    URLS "https://raw.githubusercontent.com/walbourn/directx-vs-templates/may2020/d3d12game_win32_dr/d3dx12.h"
    FILENAME "d3dx12.h"
    SHA512 "829b72ddf861652bd96518b7d54f7a103c95b4434ec022e1551fb085e4dfc8f804e01ccdb4677e3f64367553c56d35291b305e10c2ea6186ddadaaa071c6d7a2"
)

file(INSTALL ${D3DX12_H} DESTINATION ${CURRENT_PACKAGES_DIR}/include/)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "")
