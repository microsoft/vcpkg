file(APPEND "${CURRENT_PACKAGES_DIR}/include/boost/config/user.hpp" "\n#ifndef BOOST_ALL_NO_LIB\n#define BOOST_ALL_NO_LIB\n#endif\n")
file(APPEND "${CURRENT_PACKAGES_DIR}/include/boost/config/user.hpp" "\n#undef BOOST_ALL_DYN_LINK\n")

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(APPEND "${CURRENT_PACKAGES_DIR}/include/boost/config/user.hpp" "\n#define BOOST_ALL_DYN_LINK\n")
endif()
file(COPY "${SOURCE_PATH}/libs/config/checks" DESTINATION "${CURRENT_PACKAGES_DIR}/share/boost-config")
