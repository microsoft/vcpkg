# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ricab/scope_guard
    REF "v${VERSION}"
    SHA512 e2488bdfc14bd5696d3bd5909bb7355003f76258a4ab39778e17aedf338cb2ca548caf568fad93d51b602c891ba96a3c7b3ef6e21dcf4bd9cb595d01d5c063a8
    HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/scope_guard.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
