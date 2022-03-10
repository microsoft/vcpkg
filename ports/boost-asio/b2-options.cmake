if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(lib_path_suffix lib)
else()
    set(lib_path_suffix debug/lib)
endif()

if("ssl" IN_LIST FEATURES)
  function(isolate_asio_with_ssl)
    find_library(BOOST_ASIO_OPENSSL_CRYPTO_LIBRARY_PATH NAMES crypto libcrypto NAMES_PER_DIR HINTS "${CURRENT_INSTALLED_DIR}/${lib_path_suffix}" NO_CACHE REQUIRED)
    find_library(BOOST_ASIO_OPENSSL_SSL_LIBRARY_PATH NAMES ssl libssl NAMES_PER_DIR HINTS "${CURRENT_INSTALLED_DIR}/${lib_path_suffix}" NO_CACHE REQUIRED)
    list(APPEND B2_OPTIONS
      asio-with-ssl=yes
      -sASIO_CRYPTO_LIBRARY_PATH="${BOOST_ASIO_OPENSSL_CRYPTO_LIBRARY_PATH}"
      -sASIO_SSL_LIBRARY_PATH="${BOOST_ASIO_OPENSSL_SSL_LIBRARY_PATH}"
    )
    set(B2_OPTIONS ${B2_OPTIONS} PARENT_SCOPE)
  endfunction()
  isolate_asio_with_ssl()
endif()
