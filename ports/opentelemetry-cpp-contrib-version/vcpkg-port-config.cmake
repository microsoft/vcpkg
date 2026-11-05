include_guard(GLOBAL)

function(clone_opentelemetry_cpp_contrib CONTRIB_SOURCE_PATH)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-telemetry/opentelemetry-cpp-contrib
        REF 3a9af54209da6388ef2afcdb52f2f86fbe9ad6d1
        HEAD_REF main
        SHA512 81299daba70412b56a182b252b63d9017213b1b93a7a26b6ce6fb4faaa96c69b312d95514208eb90051c93166532c433bd3af4d1d3dac5146b1af21bdd170ce8
    )
    set(${CONTRIB_SOURCE_PATH} ${SOURCE_PATH} CACHE INTERNAL "")
endfunction()
