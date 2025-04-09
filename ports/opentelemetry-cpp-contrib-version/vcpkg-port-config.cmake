include_guard(GLOBAL)

function(clone_opentelemetry_cpp_contrib CONTRIB_SOURCE_PATH)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-telemetry/opentelemetry-cpp-contrib
        REF 69b8a42741b7f7063ad063d7957f7bc97bf701a4
        HEAD_REF main
        SHA512 1db239ab73f7c4d8ba97d42dd9f97b728d18a9a3a2fad342fda66231f0144aae829d9ceebd584979acc026aa9f0ca7aac0b73aa4eff2fc2f1f059b0f53eaecd3
    )
    set(${CONTRIB_SOURCE_PATH} ${SOURCE_PATH} CACHE INTERNAL "")
endfunction()
