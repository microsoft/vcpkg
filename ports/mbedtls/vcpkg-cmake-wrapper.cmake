_find_package(${ARGS})
if(WIN32 AND NOT MINGW)
    find_package(PThreads4W)
    string(FIND "${MBEDTLS_CRYPTO_LIBRARY}" "${PThreads4W_LIBRARY}" pthreads_in_mbedtls)
    if(pthreads_in_mbedtls EQUAL "-1")
        list(APPEND MBEDTLS_CRYPTO_LIBRARY ${PThreads4W_LIBRARY})
    endif()
    string(FIND "${MBEDTLS_LIBRARIES}" "${PThreads4W_LIBRARY}" pthreads_in_mbedtls)
    if(pthreads_in_mbedtls EQUAL "-1")
        list(APPEND MBEDTLS_LIBRARIES ${PThreads4W_LIBRARY})
    endif()
else()
    set(THREADS_PREFER_PTHREAD_FLAG 1)
    find_package(Threads)
    string(FIND "${MBEDTLS_CRYPTO_LIBRARY}" "${CMAKE_THREAD_LIBS_INIT}" pthreads_in_mbedtls)
    if(pthreads_in_mbedtls EQUAL "-1")
        list(APPEND MBEDTLS_CRYPTO_LIBRARY ${CMAKE_THREAD_LIBS_INIT})
    endif()
    string(FIND "${MBEDTLS_LIBRARIES}" "${CMAKE_THREAD_LIBS_INIT}" pthreads_in_mbedtls)
    if(pthreads_in_mbedtls EQUAL "-1")
        list(APPEND MBEDTLS_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})
    endif()
endif()
