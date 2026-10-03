vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/thom311/libnl/releases/download/libnl3_12_0/libnl-${VERSION}.tar.gz"
    FILENAME "libnl-${VERSION}.tar.gz"
    SHA512 6230b8cab608355346030cf32f37c43983b1d1b632cb7677ae383d4f2369b4a3773b35d2d51007d3b9c16f333aaf351682c4602b3d229cd602eec5ad53efd6f3
)

vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

# flex and bison are required to generate lib/route/{pktloc_*,ematch_*}.c
find_program(FLEX NAMES flex)
find_program(BISON NAMES bison)
if(NOT FLEX OR NOT BISON)
    message(FATAL_ERROR
        "libnl requires flex and bison to build its route parser.\n"
        "On Debian and Ubuntu derivatives: sudo apt install flex bison\n"
        "On recent Red Hat and Fedora derivatives: sudo dnf install flex bison\n"
        "On Arch Linux and derivatives: sudo pacman -S flex bison")
endif()

if("cli" IN_LIST FEATURES)
    set(CLI_OPTION --enable-cli)
else()
    set(CLI_OPTION --disable-cli)
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${CLI_OPTION}
        --disable-dependency-tracking
)
vcpkg_make_install()
vcpkg_fixup_pkgconfig()

if("cli" IN_LIST FEATURES)
    file(GLOB cli_tools "${CURRENT_PACKAGES_DIR}/bin/*")
    if(cli_tools)
        list(TRANSFORM cli_tools GET NAME)
        vcpkg_copy_tools(TOOL_NAMES ${cli_tools} AUTO_CLEAN)
    endif()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/etc"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/etc"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
