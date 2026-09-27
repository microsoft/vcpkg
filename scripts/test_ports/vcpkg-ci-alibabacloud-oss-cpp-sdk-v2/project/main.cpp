#include <alibabacloud/oss2/ClientConfiguration.h>
#include <alibabacloud/oss2/OSSClient.h>
#include <alibabacloud/oss2/credentials/CredentialsProvider.h>
#include <boost/beast/core/detail/base64.hpp>
#include <tinyxml2.h>

#include <cstring>
#include <cstdio>
#include <memory>
#include <string>

#if defined(HAS_LEGACY_OSS_SDK)
#include <alibabacloud/oss/OssClient.h>
#include <alibabacloud/oss/client/ClientConfiguration.h>
#endif

int main() {
    std::fprintf(stderr, "[diag] parsing tinyxml2 test document\n");
    tinyxml2::XMLDocument doc;
    if (doc.Parse("<root answer='42' />") != tinyxml2::XML_SUCCESS) {
        std::fprintf(stderr, "[diag] tinyxml2 parse failed\n");
        return 1;
    }

    const auto* root = doc.FirstChildElement("root");
    if (!root) {
        std::fprintf(stderr, "[diag] missing <root> element\n");
        return 1;
    }
    std::fprintf(stderr, "[diag] tinyxml2 root element: %s\n", root->Name());

    std::fprintf(stderr, "[diag] running boost::beast base64 encode\n");
    char encoded_buffer[16] = {};
    const auto encoded_size = boost::beast::detail::base64::encode(encoded_buffer, "oss", 3);
    const std::string encoded(encoded_buffer, encoded_size);
    std::fprintf(stderr, "[diag] encoded value: %s\n", encoded.c_str());

    std::fprintf(stderr, "[diag] constructing OSS SDK v2 client configuration\n");
    alibabacloud::oss2::ClientConfiguration v2_config;
    v2_config.region = "cn-hangzhou";
    v2_config.credentialsProvider = std::make_shared<alibabacloud::oss2::StaticCredentialsProvider>(
        "access-key-id", "access-key-secret");

    std::fprintf(stderr, "[diag] constructing OSS SDK v2 client\n");
    alibabacloud::oss2::OSSClient v2_client(v2_config);
    (void)v2_client;
    std::fprintf(stderr, "[diag] OSS SDK v2 client constructed successfully\n");

#if defined(HAS_LEGACY_OSS_SDK)
    std::fprintf(stderr, "[diag] initializing legacy OSS SDK\n");
    AlibabaCloud::OSS::InitializeSdk();
    AlibabaCloud::OSS::ClientConfiguration legacy_config;
    std::string legacy_md5;
    {
        std::fprintf(stderr, "[diag] constructing legacy OSS client\n");
        AlibabaCloud::OSS::OssClient legacy_client(
            "oss-cn-hangzhou.aliyuncs.com",
            "access-key-id",
            "access-key-secret",
            legacy_config);
        std::fprintf(stderr, "[diag] computing legacy SDK MD5\n");
        legacy_md5 = AlibabaCloud::OSS::ComputeContentMD5("oss", 3);
        std::fprintf(stderr, "[diag] legacy OSS client scope ending\n");
    }
    std::fprintf(stderr, "[diag] legacy SDK MD5 value: %s\n", legacy_md5.c_str());
    std::fprintf(stderr, "[diag] legacy SDK MD5 size: %zu\n", legacy_md5.size());
    AlibabaCloud::OSS::ShutdownSdk();
    std::fprintf(stderr, "[diag] shut down legacy OSS SDK\n");

    const bool ok = encoded == "b3Nz" && std::strcmp(root->Name(), "root") == 0 && legacy_md5.size() == 24;
    std::fprintf(stderr, "[diag] final result: %s\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
#else
    const bool ok = encoded == "b3Nz" && std::strcmp(root->Name(), "root") == 0;
    std::fprintf(stderr, "[diag] final result: %s\n", ok ? "PASS" : "FAIL");
    return ok ? 0 : 1;
#endif
}
