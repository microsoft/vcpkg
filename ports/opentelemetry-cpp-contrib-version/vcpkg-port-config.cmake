include_guard(GLOBAL)

function(clone_opentelemetry_cpp_contrib CONTRIB_SOURCE_PATH)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-telemetry/opentelemetry-cpp-contrib
        REF 395b18d398ae8b7836a2c186676bdc3ec679803d
        HEAD_REF main
        SHA512 66c32db347e70f48608ff3021e7a05e51b6b92851be4e7e7a4a234bb1bfc2de0e57d67506d9d47344bf6391e3f4855984aefe6bfecc712ecd7a74bd5cb4f0992
    )
    set(${CONTRIB_SOURCE_PATH} ${SOURCE_PATH} CACHE INTERNAL "")
endfunction()
