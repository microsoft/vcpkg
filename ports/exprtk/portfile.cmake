vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArashPartow/exprtk
    REF 7b993904a21639304edd4db261f6e2cdcf6d936b
    SHA512 0913d33235a1efdb64b6c661b7eeb671f87965fc0b89d102649099638aa514b83ba65eb6b8e7c4cfff9bd74d477b7f89b84aa4930b428fed3d3ec35546385e0e
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/exprtk.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/copyright")
