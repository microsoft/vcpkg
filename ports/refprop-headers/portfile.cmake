vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CoolProp/REFPROP-headers
    REF b4faab1b73911c32c4b69c526c7e92f74edb67de
    SHA512 601fcc70e7e12419e03e71b140c2fcec80eafb19f24f9871355679662802815f98cce2d167638658ba04ba7da0e811b2cf5393ced4dbe40cb2930dee75acced5
    HEAD_REF master
    PATCHES
        unicode-build.diff # https://github.com/CoolProp/REFPROP-headers/issues/21
)

file(INSTALL "${SOURCE_PATH}/REFPROP_lib.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
