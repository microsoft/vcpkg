vcpkg_replace_string("${SOURCE_PATH}/build/Jamfile.v2"
    "import ../../predef/check/predef"
    "import ../predef/check/predef"
)
file(COPY "${CURRENT_INSTALLED_DIR}/share/boost-predef/check" DESTINATION "${SOURCE_PATH}/predef")
