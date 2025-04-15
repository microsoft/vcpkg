include_guard(GLOBAL)

function(clone_opentelemetry_cpp_contrib CONTRIB_SOURCE_PATH)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-telemetry/opentelemetry-cpp-contrib
        REF 12a60a7009c900797ca0609e9f611d640da4548e
        HEAD_REF main
        SHA512 b41f3ea435f47af086e6a1477fa3f77c6d2b3e7c04e08d559cb17c35365e17395c3ee8a795e22acd0315e261fdf5713be73997e15d8c83edf87fbc463c0a3449
    )
    set(${CONTRIB_SOURCE_PATH} ${SOURCE_PATH} CACHE INTERNAL "")
endfunction()
