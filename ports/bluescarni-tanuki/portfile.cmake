vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bluescarni/tanuki
    REF 14e076abf879bcded0cc437cd09f3766969b15d1
    SHA512 e847e13e757aa2eee0ed8cde584d39545786a233905f6ed30110dcfc325dfe26eeb37ee00bff4936aa311bfdd66bb3f3f58f41aafc021701c4ea056caf964ee3
    HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/include/tanuki/tanuki.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
