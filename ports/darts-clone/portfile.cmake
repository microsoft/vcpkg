vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO s-yata/darts-clone
    REF 1767ab87cffe7302856d1bb41e1c21b1df93f19e
    SHA512 63112a4d8d6302d2602a8f161bf5fe5ec1b5b3b3097de9b28331f5261d76c06efb48601c08df26f242ddc881b917928baf54f24ccebac65da29e94380b6db0f5
    HEAD_REF master
)

# darts-clone is header-only; the whole API lives in include/darts.h.
# src/darts.cc is a command-line tool (defines main) and must not be compiled
# into a library.
file(INSTALL "${SOURCE_PATH}/include/darts.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.md")
