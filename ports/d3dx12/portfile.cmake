set(VERSION may2020)

vcpkg_download_distfile(D3DX12_H
    URLS "https://raw.githubusercontent.com/walbourn/directx-vs-templates/${VERSION}/d3d12game_win32_dr/d3dx12.h"
    FILENAME "directx-vs-templates-${VERSION}-d3dx12.h"
    SHA512 "829b72ddf861652bd96518b7d54f7a103c95b4434ec022e1551fb085e4dfc8f804e01ccdb4677e3f64367553c56d35291b305e10c2ea6186ddadaaa071c6d7a2"
)
vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/walbourn/directx-vs-templates/${VERSION}/LICENSE"
    FILENAME "directx-vs-templates-${VERSION}-LICENSE"
    SHA512 "f1c9c9b83627d00ec98c9e54c4b708716731e4b0b27f38e95d21b01f8fe4e1f27eeade5d802f93caa83ede17610411ca082ea1ce79150c372f3abdceaaa9a4a3"
)

file(INSTALL "${D3DX12_H}" DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME d3dx12.h)
file(INSTALL "${LICENSE}" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
