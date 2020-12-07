#include <catch2/catch.hpp>

#include <vcpkg/base/hash.h>

#include <algorithm>
#include <iostream>
#include <iterator>
#include <map>

namespace Hash = vcpkg::Hash;
using vcpkg::StringView;

// Require algorithm: Hash::Algorithm::Tag to be in scope
#define CHECK_HASH(size, value, real_hash)                                                                             \
    do                                                                                                                 \
    {                                                                                                                  \
        unsigned char data[size];                                                                                      \
        std::fill(std::begin(data), std::end(data), static_cast<unsigned char>(value));                                \
        const auto hash = Hash::get_bytes_hash(data, data + size, algorithm);                                          \
        REQUIRE(hash == real_hash);                                                                                    \
    } while (0)

#define CHECK_HASH_OF(data, real_hash)                                                                                 \
    do                                                                                                                 \
    {                                                                                                                  \
        const auto hash = Hash::get_bytes_hash(std::begin(data), std::end(data), algorithm);                           \
        REQUIRE(hash == real_hash);                                                                                    \
    } while (0)

#define CHECK_HASH_STRING(data, real_hash)                                                                             \
    do                                                                                                                 \
    {                                                                                                                  \
        const auto hash = Hash::get_string_hash(data, algorithm);                                                      \
        REQUIRE(hash == real_hash);                                                                                    \
    } while (0)

// Requires hasher: std::unique_ptr<Hash::Hasher> to be in scope
#define CHECK_HASH_LARGE(size, value, real_hash)                                                                       \
    do                                                                                                                 \
    {                                                                                                                  \
        hasher->clear();                                                                                               \
        std::uint64_t remaining = size;                                                                                \
        unsigned char buffer[512];                                                                                     \
        std::fill(std::begin(buffer), std::end(buffer), static_cast<unsigned char>(value));                            \
        while (remaining)                                                                                              \
        {                                                                                                              \
            if (remaining < 512)                                                                                       \
            {                                                                                                          \
                hasher->add_bytes(std::begin(buffer), std::begin(buffer) + remaining);                                 \
                remaining = 0;                                                                                         \
            }                                                                                                          \
            else                                                                                                       \
            {                                                                                                          \
                hasher->add_bytes(std::begin(buffer), std::end(buffer));                                               \
                remaining -= 512;                                                                                      \
            }                                                                                                          \
        }                                                                                                              \
        REQUIRE(hasher->get_hash() == real_hash);                                                                      \
    } while (0)

TEST_CASE ("SHA1: basic tests", "[hash][sha1]")
{
    const auto algorithm = Hash::Algorithm::Sha1;

    CHECK_HASH_STRING("", "da39a3ee5e6b4b0d3255bfef95601890afd80709");
    CHECK_HASH_STRING(";", "2d14ab97cc3dc294c51c0d6814f4ea45f4b4e312");
    CHECK_HASH_STRING("asdifasdfnas", "b77eb8a1b4c2ef6716d7d302647e4511b1a638a6");
    CHECK_HASH_STRING("asdfanvoinaoifawenflawenfiwnofvnasfjvnaslkdfjlkasjdfanm,"
                      "werflawoienfowanevoinwai32910u2740918741o;j;wejfqwioaher9283hrpf;asd",
                      "c69bcd30c196c7050906d212722dd7a7659aad04");
}

TEST_CASE ("SHA1: NIST test cases (small)", "[hash][sha1]")
{
    const auto algorithm = Hash::Algorithm::Sha1;

    CHECK_HASH_STRING("abc", "a9993e364706816aba3e25717850c26c9cd0d89d");
    CHECK_HASH_STRING("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
                      "84983e441c3bd26ebaae4aa1f95129e5e54670f1");
}

TEST_CASE ("SHA256: basic tests", "[hash][sha256]")
{
    const auto algorithm = Hash::Algorithm::Sha256;

    CHECK_HASH_STRING("", "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855");
    CHECK_HASH_STRING(";", "41b805ea7ac014e23556e98bb374702a08344268f92489a02f0880849394a1e4");
    CHECK_HASH_STRING("asdifasdfnas", "2bb1fb910831fdc11d5a3996425a84ace27aeb81c9c20ace9f60ac1b3218b291");
    CHECK_HASH_STRING("asdfanvoinaoifawenflawenfiwnofvnasfjvnaslkdfjlkasjdfanm,"
                      "werflawoienfowanevoinwai32910u2740918741o;j;wejfqwioaher9283hrpf;asd",
                      "10c98034b424d4e40ca933bc524ea38b4e53290d76e8b38edc4ea2fec7f529aa");
}

TEST_CASE ("SHA256: NIST test cases (small)", "[hash][sha256]")
{
    const auto algorithm = Hash::Algorithm::Sha256;

    CHECK_HASH(1, 0xbd, "68325720aabd7c82f30f554b313d0570c95accbb7dc4b5aae11204c08ffe732b");
    {
        const unsigned char data[] = {0xc9, 0x8c, 0x8e, 0x55};
        CHECK_HASH_OF(data, "7abc22c0ae5af26ce93dbb94433a0e0b2e119d014f8e7f65bd56c61ccccd9504");
    }
    CHECK_HASH(55, 0, "02779466cdec163811d078815c633f21901413081449002f24aa3e80f0b88ef7");
    CHECK_HASH(56, 0, "d4817aa5497628e7c77e6b606107042bbba3130888c5f47a375e6179be789fbb");
    CHECK_HASH(57, 0, "65a16cb7861335d5ace3c60718b5052e44660726da4cd13bb745381b235a1785");
    CHECK_HASH(64, 0, "f5a5fd42d16a20302798ef6ed309979b43003d2320d9f0e8ea9831a92759fb4b");
    CHECK_HASH(1000, 0, "541b3e9daa09b20bf85fa273e5cbd3e80185aa4ec298e765db87742b70138a53");
    CHECK_HASH(1000, 'A', "c2e686823489ced2017f6059b8b239318b6364f6dcd835d0a519105a1eadd6e4");
    CHECK_HASH(1005, 'U', "f4d62ddec0f3dd90ea1380fa16a5ff8dc4c54b21740650f24afc4120903552b0");
}

TEST_CASE ("SHA512: NIST test cases (small)", "[hash][sha512]")
{
    const auto algorithm = Hash::Algorithm::Sha512;

    CHECK_HASH_STRING("",
                      "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f"
                      "63b931bd47417a81a538327af927da3e");

    CHECK_HASH(111,
               0,
               "77ddd3a542e530fd047b8977c657ba6ce72f1492e360b2b2212cd264e75ec03882e4ff0525517ab4207d14c70c2259ba88d4d33"
               "5ee0e7e20543d22102ab1788c");
    CHECK_HASH(112,
               0,
               "2be2e788c8a8adeaa9c89a7f78904cacea6e39297d75e0573a73c756234534d6627ab4156b48a6657b29ab8beb73334040ad39e"
               "ad81446bb09c70704ec707952");
    CHECK_HASH(113,
               0,
               "0e67910bcf0f9ccde5464c63b9c850a12a759227d16b040d98986d54253f9f34322318e56b8feb86c5fb2270ed87f31252f7f68"
               "493ee759743909bd75e4bb544");
    CHECK_HASH(122,
               0,
               "4f3f095d015be4a7a7cc0b8c04da4aa09e74351e3a97651f744c23716ebd9b3e822e5077a01baa5cc0ed45b9249e88ab343d433"
               "3539df21ed229da6f4a514e0f");
    CHECK_HASH(1000,
               0,
               "ca3dff61bb23477aa6087b27508264a6f9126ee3a004f53cb8db942ed345f2f2d229b4b59c859220a1cf1913f34248e3803bab6"
               "50e849a3d9a709edc09ae4a76");
    CHECK_HASH(1000,
               'A',
               "329c52ac62d1fe731151f2b895a00475445ef74f50b979c6f7bb7cae349328c1d4cb4f7261a0ab43f936a24b000651d4a824fcd"
               "d577f211aef8f806b16afe8af");
    CHECK_HASH(1005,
               'U',
               "59f5e54fe299c6a8764c6b199e44924a37f59e2b56c3ebad939b7289210dc8e4c21b9720165b0f4d4374c90f1bf4fb4a5ace17a"
               "1161798015052893a48c3d161");
}

TEST_CASE ("SHA256: NIST test cases (large)", "[.][hash-expensive][sha256-expensive]")
{
    auto hasher = Hash::get_hasher_for(Hash::Algorithm::Sha256);
    CHECK_HASH_LARGE(1'000'000, 0, "d29751f2649b32ff572b5e0a9f541ea660a50f94ff0beedfb0b692b924cc8025");
    CHECK_HASH_LARGE(0x2000'0000, 'Z', "15a1868c12cc53951e182344277447cd0979536badcc512ad24c67e9b2d4f3dd");
    CHECK_HASH_LARGE(0x4100'0000, 0, "461c19a93bd4344f9215f5ec64357090342bc66b15a148317d276e31cbc20b53");
    CHECK_HASH_LARGE(0x6000'003E, 'B', "c23ce8a7895f4b21ec0daf37920ac0a262a220045a03eb2dfed48ef9b05aabea");
}

TEST_CASE ("SHA512: NIST test cases (large)", "[.][hash-expensive][sha512-expensive]")
{
    auto hasher = Hash::get_hasher_for(Hash::Algorithm::Sha512);
    CHECK_HASH_LARGE(1'000'000,
                     0,
                     "ce044bc9fd43269d5bbc946cbebc3bb711341115cc4abdf2edbc3ff2c57ad4b15deb699bda257fea5aef9c6e55fcf4cf9"
                     "dc25a8c3ce25f2efe90908379bff7ed");
    CHECK_HASH_LARGE(0x2000'0000,
                     'Z',
                     "da172279f3ebbda95f6b6e1e5f0ebec682c25d3d93561a1624c2fa9009d64c7e9923f3b46bcaf11d39a531f43297992ba"
                     "4155c7e827bd0f1e194ae7ed6de4cac");
    CHECK_HASH_LARGE(0x4100'0000,
                     0,
                     "14b1be901cb43549b4d831e61e5f9df1c791c85b50e85f9d6bc64135804ad43ce8402750edbe4e5c0fc170b99cf78b9f4"
                     "ecb9c7e02a157911d1bd1832d76784f");
    CHECK_HASH_LARGE(0x6000'003E,
                     'B',
                     "fd05e13eb771f05190bd97d62647157ea8f1f6949a52bb6daaedbad5f578ec59b1b8d6c4a7ecb2feca6892b4dc1387716"
                     "70a0f3bd577eea326aed40ab7dd58b1");
}

#if defined(CATCH_CONFIG_ENABLE_BENCHMARKING)
using Catch::Benchmark::Chronometer;
void benchmark_hasher(Chronometer& meter, Hash::Hasher& hasher, std::uint64_t size, unsigned char byte) noexcept
{
    unsigned char buffer[1024];
    std::fill(std::begin(buffer), std::end(buffer), byte);

    meter.measure([&] {
        hasher.clear();
        std::uint64_t remaining = size;
        while (remaining)
        {
            if (remaining < 512)
            {
                hasher.add_bytes(std::begin(buffer), std::begin(buffer) + remaining);
                remaining = 0;
            }
            else
            {
                hasher.add_bytes(std::begin(buffer), std::end(buffer));
                remaining -= 512;
            }
        }
        hasher.get_hash();
    });
}

TEST_CASE ("SHA1: benchmark", "[.][hash][sha256][!benchmark]")
{
    using Catch::Benchmark::Chronometer;

    auto hasher = Hash::get_hasher_for(Hash::Algorithm::Sha1);

    BENCHMARK_ADVANCED("0 x 1'000'000")(Catch::Benchmark::Chronometer meter)
    {
        benchmark_hasher(meter, *hasher, 1'000'000, 0);
    };
    BENCHMARK_ADVANCED("'Z' x 0x2000'0000")(Catch::Benchmark::Chronometer meter)
    {
        benchmark_hasher(meter, *hasher, 0x2000'0000, 'Z');
    };
    BENCHMARK_ADVANCED("0 x 0x4100'0000")(Catch::Benchmark::Chronometer meter)
    {
        benchmark_hasher(meter, *hasher, 0x4100'0000, 0);
    };
    BENCHMARK_ADVANCED("'B' x 0x6000'003E")(Catch::Benchmark::Chronometer meter)
    {
        benchmark_hasher(meter, *hasher, 0x6000'003E, 'B');
    };
}

TEST_CASE ("SHA256: benchmark", "[.][hash][sha256][!benchmark]")
{
    using Catch::Benchmark::Chronometer;

    auto hasher = Hash::get_hasher_for(Hash::Algorithm::Sha256);

    BENCHMARK_ADVANCED("0 x 1'000'000")(Catch::Benchmark::Chronometer meter)
    {
        benchmark_hasher(meter, *hasher, 1'000'000, 0);
    };
    BENCHMARK_ADVANCED("'Z' x 0x2000'0000")(Catch::Benchmark::Chronometer meter)
    {
        benchmark_hasher(meter, *hasher, 0x2000'0000, 'Z');
    };
    BENCHMARK_ADVANCED("0 x 0x4100'0000")(Catch::Benchmark::Chronometer meter)
    {
        benchmark_hasher(meter, *hasher, 0x4100'0000, 0);
    };
    BENCHMARK_ADVANCED("'B' x 0x6000'003E")(Catch::Benchmark::Chronometer meter)
    {
        benchmark_hasher(meter, *hasher, 0x6000'003E, 'B');
    };
}

TEST_CASE ("SHA512: large -- benchmark", "[.][hash][sha512][!benchmark]")
{
    auto hasher = Hash::get_hasher_for(Hash::Algorithm::Sha512);

    BENCHMARK_ADVANCED("0 x 1'000'000")(Catch::Benchmark::Chronometer meter)
    {
        benchmark_hasher(meter, *hasher, 1'000'000, 0);
    };
    BENCHMARK_ADVANCED("'Z' x 0x2000'0000")(Catch::Benchmark::Chronometer meter)
    {
        benchmark_hasher(meter, *hasher, 0x2000'0000, 'Z');
    };
    BENCHMARK_ADVANCED("0 x 0x4100'0000")(Catch::Benchmark::Chronometer meter)
    {
        benchmark_hasher(meter, *hasher, 0x4100'0000, 0);
    };
    BENCHMARK_ADVANCED("'B' x 0x6000'003E")(Catch::Benchmark::Chronometer meter)
    {
        benchmark_hasher(meter, *hasher, 0x6000'003E, 'B');
    };
}
#endif
