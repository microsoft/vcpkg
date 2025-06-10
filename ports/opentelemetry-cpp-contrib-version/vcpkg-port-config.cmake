include_guard(GLOBAL)

function(clone_opentelemetry_cpp_contrib CONTRIB_SOURCE_PATH)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-telemetry/opentelemetry-cpp-contrib
        REF bfbaf5e529b6c8a661971b6cc94fb09cf5cd148a
        HEAD_REF main
        SHA512 cdf550ad1d3c3dcae33f70a4747cd30d961f7b66a5ce1897aa6f6ab9cbc3a0e6ad46e134d8f32bc185c7bf4414b6aa6981cbd391336597cff03e2aeb4d1bb4d1
    )
    set(${CONTRIB_SOURCE_PATH} ${SOURCE_PATH} CACHE INTERNAL "")
endfunction()
