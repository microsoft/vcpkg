if(VCPKG_TARGET_IS_WINDOWS)
    find_program(PWSH_PATH pwsh)
    execute_process(
        COMMAND "${PWSH_PATH}" -ExecutionPolicy ByPass -c "irm https://github.com/astral-sh/uv/releases/download/${VERSION}/uv-installer.ps1 | iex"
        COMMAND_ERROR_IS_FATAL ANY
    )
else()
    find_dependency(CURL)
    find_program(BASH NAME bash HINTS ${MSYS_ROOT}/usr/bin REQUIRED)
    execute_process(
        COMMAND "${CURL}" --proto '=https' --tlsv1.2 -LsSf "https://github.com/astral-sh/uv/releases/download/${VERSION}/uv-installer.sh" | ${BASH}
        COMMAND_ERROR_IS_FATAL ANY
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO astral-sh/uv
    REF ${VERSION}
    SHA512 9582d8f97515bc182d699f9994a21f7c883203dabb338848c751d97737c864272e5efbaf3a81d08545caac6643ba9cbde2fe11769ec6b98062416d7501d022f8
    HEAD_REF main
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-MIT")
