_find_package(${ARGS})

# workaround for https://gitlab.kitware.com/cmake/cmake/-/issues/19263
list(APPEND OPENSSL_LIBRARIES crypt32 ws2_32)
set_property(TARGET OpenSSL::SSL
             APPEND
             PROPERTY INTERFACE_LINK_LIBRARIES
             crypt32 ws2_32)
set_property(TARGET OpenSSL::Crypto
             APPEND
             PROPERTY INTERFACE_LINK_LIBRARIES
             crypt32 ws2_32)
