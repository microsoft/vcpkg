set(VERSION may2021)

# The official D3DX12.H is hosted on https://github.com/microsoft/DirectX-Headers.
#
# This port uses the version from directx-vs-templates instead because it is compatible with multiple
# versions of the Windows 10 SDK. The official version only supports the 'latest' Windows 10 SDK.

message(NOTICE "Consider using the 'directx-headers' port instead. See https://aka.ms/directx12agility")

vcpkg_download_distfile(D3DX12_H
    URLS "https://raw.githubusercontent.com/walbourn/directx-vs-templates/${VERSION}/d3d12game_win32_dr/d3dx12.h"
    FILENAME "directx-vs-templates-${VERSION}-d3dx12.h"
    SHA512 b053a8e6593c701a0827f8a52f20e160070b8b71242fd60a57617e46b87e909e11f814fc15b084b4f83b7ff5b9a562280da64a77cee3a171ef17839315df4245
)
vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/walbourn/directx-vs-templates/${VERSION}/LICENSE"
    FILENAME "directx-vs-templates-${VERSION}-LICENSE"
    SHA512 ce7d8ec7bfb58ef36a95b20f6f0fc4e3cd4923bb3ac6bd1f62e8215df2ee83d2a594ce84b15951310f05a819a0370468af781e73a10e536d23965421466851f4
)

file(INSTALL "${D3DX12_H}" DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME d3dx12.h)
file(INSTALL "${LICENSE}" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
