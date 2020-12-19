vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMesh
    REF nov2020b
    SHA512 c502bc77e22346c3e4b0e13764b1ffcaec9f62ace76a9ee5d1e3226d550e27b4f1d6081093211370b6b963ccfb564aec62641ca455f6c18301a2851fcb879b62
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS 
    FEATURES
        dx12 BUILD_DX12
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS} -DBUILD_TOOLS=OFF
)

vcpkg_build_cmake()

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

vcpkg_download_distfile(meshconvert
    URLS "https://github.com/Microsoft/DirectXMesh/releases/download/nov2020/meshconvert.exe"
    FILENAME "meshconvert.exe"
    SHA512 189552c74dc634f673a0d15851d7bb7c42c860023b1488086a9904323fc45207244c159c8848a211afafe258825f5051ee6fd85080da3f7f4afdf910764ca8ec
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/directxmesh/")

file(INSTALL
    ${DOWNLOADS}/meshconvert.exe
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/directxmesh/)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
