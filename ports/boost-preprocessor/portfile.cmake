# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/preprocessor
    REF boost-1.81.0
    SHA512 f6905f711c957dceb83170a79b13487a1dfc237699a4ce1d1efaa1fa47ad93b66f0032b5585d53c3f771409e30da8f866eb4fc317ea7c21b1f42a46d9943339e
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
