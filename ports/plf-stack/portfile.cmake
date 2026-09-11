set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_stack
    REF 36fba46175151a9f9ed237f26f407b5c4a4f06b2 # 2.0.21
    SHA512 0f605d003abcf9b1d772a4615db68b1230fbea6ef841f2e03829d2c9c08cacbd8c48872abb0c532296ee880c89079b3d8c64663afb40cc010749c99e9f3b572f
    HEAD_REF master
)

file(
    COPY
        "${SOURCE_PATH}/plf_stack.h"
        "${SOURCE_PATH}/plf_tools.h"
        "${SOURCE_PATH}/plf_tools_undef.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
)
