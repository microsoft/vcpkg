vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/ndis-driver-library
    REF cde7dea8846fe72b60fe84ef0c78855711a4dd93
    SHA512 31f13cf806c136d5ed079f6e048f2183ce3dc69d5d27093945b0ea174b6f8a49ae1f9574b90143af6c2190399ab9af8f46f7b2980fcb4b76793818610d8a7b3a
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/src/include/ndis" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
