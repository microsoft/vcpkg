# Header-only library
vcpkg_download_distfile(D3DX12_H
    URLS "https://raw.githubusercontent.com/microsoft/DirectX-Graphics-Samples/master/Libraries/D3DX12/d3dx12.h"
    FILENAME "d3dx12.h"
    SHA512 "e41936bec06db9e22e953b31de418981343d5a4df4979d359a4c427d90f58ccee41fba73b9b0b8251d957dbdf4f9b7730ee11846f59f23636b862685a0fc21dc"
)

file(INSTALL ${D3DX12_H} DESTINATION ${CURRENT_PACKAGES_DIR}/include/)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "")
