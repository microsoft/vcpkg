vcpkg_replace_string("${SOURCE_PATH}/build/Jamfile.v2"
    "import config : requires ;"
    "import ../config/checks/config : requires ;"
)
file(COPY "${CURRENT_INSTALLED_DIR}/share/boost-config/checks" DESTINATION "${SOURCE_PATH}/config")
