include_guard(GLOBAL)

function(clone_opentelemetry_cpp_contrib CONTRIB_SOURCE_PATH)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-telemetry/opentelemetry-cpp-contrib
        REF 2297c4feed5a623e7b9cff84d4398495a20ee7d2
        HEAD_REF main
        SHA512 88e42c215caa983d5eed78fd387fd8735f03fbc308e12fd2afcb61760ab399e31c17ea68ca2d69e4571f61bf1b965f67ff4058881c4ab3b0d86c33932bdf5663
    )
    set(${CONTRIB_SOURCE_PATH} ${SOURCE_PATH} CACHE INTERNAL "")
endfunction()
