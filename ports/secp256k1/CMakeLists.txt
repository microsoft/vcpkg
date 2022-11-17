cmake_minimum_required(VERSION 3.8)
project(secp256k1 C)

option(INSTALL_HEADERS "Install header files" ON)
option(BUILD_TOOLS "Build tools" OFF)
option(BUILD_EXAMPLES "Build examples" OFF)

add_definitions(
    -DENABLE_MODULE_ECDH
    -DENABLE_MODULE_RECOVERY
    -DENABLE_MODULE_EXTRAKEYS
    -DENABLE_MODULE_SCHNORRSIG
)

file(GLOB SOURCES src/secp256k1.c)
add_library(secp256k1 ${SOURCES})

target_include_directories(secp256k1 PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src> $<INSTALL_INTERFACE:include>)

file(GLOB SOURCES_PRECOMP src/precomputed_ecmult.c src/precomputed_ecmult_gen.c)
add_library(secp256k1_precomputed ${SOURCES_PRECOMP})

target_include_directories(secp256k1_precomputed PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>)

if (BUILD_TOOLS)
    add_executable(bench src/bench.c)
    target_link_libraries(bench PRIVATE secp256k1 secp256k1_precomputed)

    add_executable(bench_internal src/bench_internal.c)
    target_link_libraries(bench_internal PRIVATE secp256k1_precomputed)

    add_executable(bench_ecmult src/bench_ecmult.c)
    target_link_libraries(bench_ecmult PRIVATE secp256k1_precomputed)

    install(TARGETS bench bench_internal bench_ecmult RUNTIME DESTINATION bin)
endif()

if (BUILD_EXAMPLES)
    add_executable(ecdsa_example examples/ecdsa.c)
    target_include_directories(ecdsa_example PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
    target_link_libraries(ecdsa_example PRIVATE secp256k1 secp256k1_precomputed)
    if (WIN32)
        target_link_libraries(ecdsa_example PRIVATE Bcrypt)
    endif()

    add_executable(ecdh_example examples/ecdh.c)
    target_include_directories(ecdh_example PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
    target_link_libraries(ecdh_example PRIVATE secp256k1 secp256k1_precomputed)
    if (WIN32)
        target_link_libraries(ecdh_example PRIVATE Bcrypt)
    endif()

    add_executable(schnorr_example examples/schnorr.c)
    target_include_directories(schnorr_example PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
    target_link_libraries(schnorr_example PRIVATE secp256k1 secp256k1_precomputed)
    if (WIN32)
        target_link_libraries(schnorr_example PRIVATE Bcrypt)
    endif()
    
    install(TARGETS ecdsa_example ecdh_example schnorr_example RUNTIME DESTINATION bin)
endif()

if(INSTALL_HEADERS)
    file(GLOB HEADERS include/*.h)
    install(FILES ${HEADERS} DESTINATION include)
endif()

install(TARGETS secp256k1 EXPORT unofficial-secp256k1-config
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(TARGETS secp256k1_precomputed EXPORT unofficial-secp256k1-config
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(
    EXPORT unofficial-secp256k1-config
    FILE unofficial-secp256k1-config.cmake
    NAMESPACE unofficial::
    DESTINATION share/unofficial-secp256k1
)
