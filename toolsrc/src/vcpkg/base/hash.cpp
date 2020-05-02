#include "pch.h"

#include <vcpkg/base/hash.h>

#include <vcpkg/base/checks.h>
#include <vcpkg/base/uint128.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#if defined(_WIN32)
#include <bcrypt.h>
#pragma comment(lib, "bcrypt")

#ifndef NT_SUCCESS
#define NT_SUCCESS(Status) (((NTSTATUS)(Status)) >= 0)
#endif

#endif

namespace vcpkg::Hash
{
    using uchar = unsigned char;

    Optional<Algorithm> algorithm_from_string(StringView sv) noexcept
    {
        if (Strings::case_insensitive_ascii_equals(sv, "SHA1"))
        {
            return {Algorithm::Sha1};
        }
        if (Strings::case_insensitive_ascii_equals(sv, "SHA256"))
        {
            return {Algorithm::Sha256};
        }
        if (Strings::case_insensitive_ascii_equals(sv, "SHA512"))
        {
            return {Algorithm::Sha512};
        }

        return {};
    }

    const char* to_string(Algorithm algo) noexcept
    {
        switch (algo)
        {
            case Algorithm::Sha1: return "SHA1";
            case Algorithm::Sha256: return "SHA256";
            case Algorithm::Sha512: return "SHA512";
            default: vcpkg::Checks::exit_fail(VCPKG_LINE_INFO);
        }
    }

    template <class UIntTy>
    auto top_bits(UIntTy x) -> std::enable_if_t<std::is_unsigned<UIntTy>::value, uchar> {
        return static_cast<uchar>(x >> ((sizeof(x) - 1) * 8));
    }
    template <class UIntTy>
    auto top_bits(UIntTy x) -> decltype(top_bits(x.top_64_bits())) {
        return top_bits(x.top_64_bits());
    }

    // treats UIntTy as big endian for the purpose of this mapping
    template<class UIntTy>
    static std::string to_hex(const UIntTy* start, const UIntTy* end) noexcept
    {
        static constexpr char HEX_MAP[] = "0123456789abcdef";

        std::string output;
        output.resize(2 * sizeof(UIntTy) * (end - start));

        std::size_t output_index = 0;
        for (const UIntTy* it = start; it != end; ++it)
        {
            // holds *it in a big-endian buffer, for copying into output
            uchar buff[sizeof(UIntTy)];
            UIntTy tmp = *it;
            for (uchar& ch : buff)
            {
                ch = top_bits(tmp);
                tmp = UIntTy(tmp << 8);
            }

            for (const auto byte : buff)
            {
                // high
                output[output_index] = HEX_MAP[(byte & 0xF0) >> 4];
                ++output_index;
                // low
                output[output_index] = HEX_MAP[byte & 0x0F];
                ++output_index;
            }
        }

        return output;
    }

    namespace
    {
#if defined(_WIN32)
        BCRYPT_ALG_HANDLE get_alg_handle(LPCWSTR algorithm_identifier) noexcept
        {
            BCRYPT_ALG_HANDLE result;
            auto error = BCryptOpenAlgorithmProvider(&result, algorithm_identifier, nullptr, 0);
            if (!NT_SUCCESS(error))
            {
                Checks::exit_with_message(VCPKG_LINE_INFO, "Failure to open algorithm: %ls", algorithm_identifier);
            }

            return result;
        }

        struct BCryptHasher : Hasher
        {
            static const BCRYPT_ALG_HANDLE sha1_alg_handle;
            static const BCRYPT_ALG_HANDLE sha256_alg_handle;
            static const BCRYPT_ALG_HANDLE sha512_alg_handle;

            explicit BCryptHasher(Algorithm algo) noexcept
            {
                switch (algo)
                {
                    case Algorithm::Sha1: alg_handle = sha1_alg_handle; break;
                    case Algorithm::Sha256: alg_handle = sha256_alg_handle; break;
                    case Algorithm::Sha512: alg_handle = sha512_alg_handle; break;
                    default: Checks::exit_with_message(VCPKG_LINE_INFO, "Unknown algorithm");
                }

                clear();
            }

            virtual void add_bytes(const void* start_, const void* end_) noexcept override
            {
                // BCryptHashData takes its input as non-const, but does not modify it
                uchar* start = const_cast<uchar*>(static_cast<const uchar*>(start_));
                const uchar* end = static_cast<const uchar*>(end_);
                Checks::check_exit(VCPKG_LINE_INFO, end - start >= 0);

                // only matters on 64-bit -- BCryptHasher takes an unsigned long
                // length, so if you have an array bigger than 2**32-1 elements,
                // you have a problem.
#if defined(_M_AMD64) || defined(_M_ARM64)
                constexpr std::ptrdiff_t max = std::numeric_limits<unsigned long>::max();
                Checks::check_exit(VCPKG_LINE_INFO, end - start <= max);
#endif

                const auto length = static_cast<unsigned long>(end - start);
                const NTSTATUS error_code = BCryptHashData(hash_handle, start, length, 0);
                Checks::check_exit(VCPKG_LINE_INFO, NT_SUCCESS(error_code), "Failed to process a chunk");
            }

            virtual void clear() noexcept override
            {
                if (hash_handle) BCryptDestroyHash(hash_handle);
                const NTSTATUS error_code = BCryptCreateHash(alg_handle, &hash_handle, nullptr, 0, nullptr, 0, 0);
                Checks::check_exit(VCPKG_LINE_INFO, NT_SUCCESS(error_code), "Failed to initialize the hasher");
            }

            virtual std::string get_hash() noexcept override
            {
                const auto hash_size = get_hash_buffer_size();
                const auto buffer = std::make_unique<uchar[]>(hash_size);
                const auto hash = buffer.get();

                const NTSTATUS error_code = BCryptFinishHash(hash_handle, hash, hash_size, 0);
                Checks::check_exit(VCPKG_LINE_INFO, NT_SUCCESS(error_code), "Failed to finalize the hash");
                return to_hex(hash, hash + hash_size);
            }

            ~BCryptHasher() { BCryptDestroyHash(hash_handle); }

        private:
            unsigned long get_hash_buffer_size() const
            {
                unsigned long hash_buffer_bytes;
                unsigned long cb_data;
                const NTSTATUS error_code = BCryptGetProperty(alg_handle,
                                                              BCRYPT_HASH_LENGTH,
                                                              reinterpret_cast<uchar*>(&hash_buffer_bytes),
                                                              sizeof(hash_buffer_bytes),
                                                              &cb_data,
                                                              0);
                Checks::check_exit(VCPKG_LINE_INFO, NT_SUCCESS(error_code), "Failed to get hash length");

                return hash_buffer_bytes;
            }

            BCRYPT_HASH_HANDLE hash_handle = nullptr;
            BCRYPT_ALG_HANDLE alg_handle = nullptr;
        };

        const BCRYPT_ALG_HANDLE BCryptHasher::sha1_alg_handle = get_alg_handle(BCRYPT_SHA1_ALGORITHM);
        const BCRYPT_ALG_HANDLE BCryptHasher::sha256_alg_handle = get_alg_handle(BCRYPT_SHA256_ALGORITHM);
        const BCRYPT_ALG_HANDLE BCryptHasher::sha512_alg_handle = get_alg_handle(BCRYPT_SHA512_ALGORITHM);
#else

        template<class WordTy>
        static WordTy shl(WordTy value, int by) noexcept
        {
            return value << by;
        }

        static std::uint32_t shr32(std::uint32_t value, int by) noexcept { return value >> by; }
        static std::uint32_t rol32(std::uint32_t value, int by) noexcept
        {
            return (value << by) | (value >> (32 - by));
        }
        static std::uint32_t ror32(std::uint32_t value, int by) noexcept
        {
            return (value >> by) | (value << (32 - by));
        }

        static std::uint64_t shr64(std::uint64_t value, int by) noexcept { return value >> by; }
        static std::uint64_t ror64(std::uint64_t value, int by) noexcept
        {
            return (value >> by) | (value << (64 - by));
        }

        template<class ShaAlgorithm>
        struct ShaHasher final : Hasher
        {
            ShaHasher() = default;

            virtual void add_bytes(const void* start, const void* end) noexcept override
            {
                for (;;)
                {
                    start = add_to_unprocessed(start, end);
                    if (!start)
                    {
                        break; // done
                    }

                    m_impl.process_full_chunk(m_chunk);
                    m_current_chunk_size = 0;
                }
            }

            virtual void clear() noexcept override
            {
                m_impl.clear();

                // m_chunk is theoretically uninitialized, so no need to reset it
                m_current_chunk_size = 0;
                m_message_length = 0;
            }

            virtual std::string get_hash() noexcept override
            {
                process_last_chunk();
                return to_hex(m_impl.begin(), m_impl.end());
            }

        private:
            // if unprocessed gets filled,
            // returns a pointer to the remainder of the block (which might be end)
            // else, returns nullptr
            const void* add_to_unprocessed(const void* start_, const void* end_) noexcept
            {
                const uchar* start = static_cast<const uchar*>(start_);
                const uchar* end = static_cast<const uchar*>(end_);

                const auto remaining = chunk_size - m_current_chunk_size;

                const std::size_t message_length = end - start;
                if (message_length >= remaining)
                {
                    std::copy(start, start + remaining, chunk_begin());
                    m_current_chunk_size += remaining;
                    m_message_length += remaining * 8;
                    return start + remaining;
                }
                else
                {
                    std::copy(start, end, chunk_begin());
                    m_current_chunk_size += message_length;
                    m_message_length += message_length * 8;
                    return nullptr;
                }
            }

            // called before `get_hash`
            void process_last_chunk() noexcept
            {
                const auto message_length = m_message_length;

                // append the bit '1' to the message
                {
                    const uchar temp = 0x80;
                    add_to_unprocessed(&temp, &temp + 1);
                }

                // append 0 to the message so that the resulting length is just enough
                // to add the message length
                if (chunk_size - m_current_chunk_size < sizeof(m_message_length))
                {
                    // not enough space to add the message length
                    // just resize and process full chunk
                    std::fill(chunk_begin(), m_chunk.end(), static_cast<uchar>(0));
                    m_impl.process_full_chunk(m_chunk);
                    m_current_chunk_size = 0;
                }

                const auto before_length = m_chunk.end() - sizeof(m_message_length);
                std::fill(chunk_begin(), before_length, static_cast<uchar>(0));
                std::generate(before_length, m_chunk.end(), [length = message_length]() mutable {
                    const auto result = top_bits(length);
                    length <<= 8;
                    return result;
                });

                m_impl.process_full_chunk(m_chunk);
            }

            auto chunk_begin() { return m_chunk.begin() + m_current_chunk_size; }

            using underlying_type = typename ShaAlgorithm::underlying_type;
            using message_length_type = typename ShaAlgorithm::message_length_type;
            constexpr static std::size_t chunk_size = ShaAlgorithm::chunk_size;

            ShaAlgorithm m_impl{};

            std::array<uchar, chunk_size> m_chunk{};
            std::size_t m_current_chunk_size = 0;
            message_length_type m_message_length = 0;
        };
        template<class WordTy>
        inline void sha_fill_initial_words(const uchar* chunk, WordTy* words)
        {
            // break chunk into 16 N-bit words
            for (std::size_t word = 0; word < 16; ++word)
            {
                words[word] = 0;
                // big-endian -- so the earliest i becomes the most significant
                for (std::size_t byte = 0; byte < sizeof(WordTy); ++byte)
                {
                    const auto bits_to_shift = static_cast<int>(8 * (sizeof(WordTy) - 1 - byte));
                    words[word] |= shl<WordTy>(chunk[word * sizeof(WordTy) + byte], bits_to_shift);
                }
            }
        }

        struct Sha1Algorithm
        {
            using underlying_type = std::uint32_t;
            using message_length_type = std::uint64_t;
            constexpr static std::size_t chunk_size = 64; // = 512 / 8
            constexpr static std::size_t number_of_rounds = 80;

            Sha1Algorithm() noexcept { clear(); }

            void process_full_chunk(const std::array<uchar, chunk_size>& chunk) noexcept
            {
                std::uint32_t words[80];

                sha_fill_initial_words(&chunk[0], words);
                for (std::size_t i = 16; i < number_of_rounds; ++i)
                {
                    const auto sum = words[i - 3] ^ words[i - 8] ^ words[i - 14] ^ words[i - 16];
                    words[i] = rol32(sum, 1);
                }

                std::uint32_t a = m_digest[0];
                std::uint32_t b = m_digest[1];
                std::uint32_t c = m_digest[2];
                std::uint32_t d = m_digest[3];
                std::uint32_t e = m_digest[4];

                for (std::size_t i = 0; i < number_of_rounds; ++i)
                {
                    std::uint32_t f;
                    std::uint32_t k;

                    if (i < 20)
                    {
                        f = (b & c) | (~b & d);
                        k = 0x5A827999;
                    }
                    else if (i < 40)
                    {
                        f = b ^ c ^ d;
                        k = 0x6ED9EBA1;
                    }
                    else if (i < 60)
                    {
                        f = (b & c) | (b & d) | (c & d);
                        k = 0x8F1BBCDC;
                    }
                    else
                    {
                        f = b ^ c ^ d;
                        k = 0xCA62C1D6;
                    }

                    auto tmp = rol32(a, 5) + f + e + k + words[i];
                    e = d;
                    d = c;
                    c = rol32(b, 30);
                    b = a;
                    a = tmp;
                }

                m_digest[0] += a;
                m_digest[1] += b;
                m_digest[2] += c;
                m_digest[3] += d;
                m_digest[4] += e;
            }

            void clear() noexcept
            {
                m_digest[0] = 0x67452301;
                m_digest[1] = 0xEFCDAB89;
                m_digest[2] = 0x98BADCFE;
                m_digest[3] = 0x10325476;
                m_digest[4] = 0xC3D2E1F0;
            }

            const std::uint32_t* begin() const noexcept { return &m_digest[0]; }
            const std::uint32_t* end() const noexcept { return &m_digest[5]; }

            std::uint32_t m_digest[5];
        };

        struct Sha256Algorithm
        {
            using underlying_type = std::uint32_t;
            using message_length_type = std::uint64_t;
            constexpr static std::size_t chunk_size = 64;

            constexpr static std::size_t number_of_rounds = 64;

            Sha256Algorithm() noexcept { clear(); }

            void process_full_chunk(const std::array<uchar, chunk_size>& chunk) noexcept
            {
                std::uint32_t words[64];

                sha_fill_initial_words(&chunk[0], words);

                for (std::size_t i = 16; i < number_of_rounds; ++i)
                {
                    const auto w0 = words[i - 15];
                    const auto s0 = ror32(w0, 7) ^ ror32(w0, 18) ^ shr32(w0, 3);
                    const auto w1 = words[i - 2];
                    const auto s1 = ror32(w1, 17) ^ ror32(w1, 19) ^ shr32(w1, 10);
                    words[i] = words[i - 16] + s0 + words[i - 7] + s1;
                }

                std::uint32_t local[8];
                std::copy(begin(), end(), std::begin(local));

                for (std::size_t i = 0; i < number_of_rounds; ++i)
                {
                    const auto a = local[0];
                    const auto b = local[1];
                    const auto c = local[2];

                    const auto s0 = ror32(a, 2) ^ ror32(a, 13) ^ ror32(a, 22);
                    const auto maj = (a & b) ^ (a & c) ^ (b & c);
                    const auto tmp1 = s0 + maj;

                    const auto e = local[4];

                    const auto s1 = ror32(e, 6) ^ ror32(e, 11) ^ ror32(e, 25);
                    const auto ch = (e & local[5]) ^ (~e & local[6]);
                    const auto tmp2 = local[7] + s1 + ch + round_constants[i] + words[i];

                    for (std::size_t j = 7; j > 0; --j)
                    {
                        local[j] = local[j - 1];
                    }
                    local[4] += tmp2;
                    local[0] = tmp1 + tmp2;
                }

                for (std::size_t i = 0; i < 8; ++i)
                {
                    m_digest[i] += local[i];
                }
            }

            void clear() noexcept
            {
                m_digest[0] = 0x6a09e667;
                m_digest[1] = 0xbb67ae85;
                m_digest[2] = 0x3c6ef372;
                m_digest[3] = 0xa54ff53a;
                m_digest[4] = 0x510e527f;
                m_digest[5] = 0x9b05688c;
                m_digest[6] = 0x1f83d9ab;
                m_digest[7] = 0x5be0cd19;
            }

            constexpr static std::array<std::uint32_t, number_of_rounds> round_constants = {
                0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
                0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
                0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
                0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
                0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
                0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
                0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
                0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2};

            std::uint32_t* begin() noexcept { return &m_digest[0]; }
            std::uint32_t* end() noexcept { return &m_digest[8]; }

            std::uint32_t m_digest[8];
        };

        struct Sha512Algorithm
        {
            using underlying_type = std::uint64_t;
            using message_length_type = UInt128;
            constexpr static std::size_t chunk_size = 128; // = 1024 / 8

            constexpr static std::size_t number_of_rounds = 80;

            Sha512Algorithm() noexcept { clear(); }

            void process_full_chunk(const std::array<uchar, chunk_size>& chunk) noexcept
            {
                std::uint64_t words[80];

                sha_fill_initial_words(&chunk[0], words);

                for (std::size_t i = 16; i < number_of_rounds; ++i)
                {
                    const auto w0 = words[i - 15];
                    const auto s0 = ror64(w0, 1) ^ ror64(w0, 8) ^ shr64(w0, 7);
                    const auto w1 = words[i - 2];
                    const auto s1 = ror64(w1, 19) ^ ror64(w1, 61) ^ shr64(w1, 6);
                    words[i] = words[i - 16] + s0 + words[i - 7] + s1;
                }

                std::uint64_t local[8];
                std::copy(begin(), end(), std::begin(local));

                for (std::size_t i = 0; i < number_of_rounds; ++i)
                {
                    const auto a = local[0];
                    const auto b = local[1];
                    const auto c = local[2];

                    const auto s0 = ror64(a, 28) ^ ror64(a, 34) ^ ror64(a, 39);
                    const auto maj = (a & b) ^ (a & c) ^ (b & c);
                    const auto tmp0 = s0 + maj;

                    const auto e = local[4];

                    const auto s1 = ror64(e, 14) ^ ror64(e, 18) ^ ror64(e, 41);
                    const auto ch = (e & local[5]) ^ (~e & local[6]);
                    const auto tmp1 = local[7] + s1 + ch + round_constants[i] + words[i];

                    for (std::size_t j = 7; j > 0; --j)
                    {
                        local[j] = local[j - 1];
                    }
                    local[4] += tmp1;
                    local[0] = tmp0 + tmp1;
                }

                for (std::size_t i = 0; i < 8; ++i)
                {
                    m_digest[i] += local[i];
                }
            }

            void clear() noexcept
            {
                m_digest[0] = 0x6a09e667f3bcc908;
                m_digest[1] = 0xbb67ae8584caa73b;
                m_digest[2] = 0x3c6ef372fe94f82b;
                m_digest[3] = 0xa54ff53a5f1d36f1;
                m_digest[4] = 0x510e527fade682d1;
                m_digest[5] = 0x9b05688c2b3e6c1f;
                m_digest[6] = 0x1f83d9abfb41bd6b;
                m_digest[7] = 0x5be0cd19137e2179;
            }

            constexpr static std::array<std::uint64_t, number_of_rounds> round_constants = {
                0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc, 0x3956c25bf348b538,
                0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118, 0xd807aa98a3030242, 0x12835b0145706fbe,
                0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2, 0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235,
                0xc19bf174cf692694, 0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65,
                0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5, 0x983e5152ee66dfab,
                0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4, 0xc6e00bf33da88fc2, 0xd5a79147930aa725,
                0x06ca6351e003826f, 0x142929670a0e6e70, 0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed,
                0x53380d139d95b3df, 0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b,
                0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30, 0xd192e819d6ef5218,
                0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8, 0x19a4c116b8d2d0c8, 0x1e376c085141ab53,
                0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8, 0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373,
                0x682e6ff3d6b2b8a3, 0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec,
                0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b, 0xca273eceea26619c,
                0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178, 0x06f067aa72176fba, 0x0a637dc5a2c898a6,
                0x113f9804bef90dae, 0x1b710b35131c471b, 0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc,
                0x431d67c49c100d4c, 0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817};

            std::uint64_t* begin() noexcept { return &m_digest[0]; }
            std::uint64_t* end() noexcept { return &m_digest[8]; }

            std::uint64_t m_digest[8];
        };

        // This is required on older compilers, since it was required in C++14
        constexpr std::array<std::uint32_t, Sha256Algorithm::number_of_rounds> Sha256Algorithm::round_constants;
        constexpr std::array<std::uint64_t, Sha512Algorithm::number_of_rounds> Sha512Algorithm::round_constants;
#endif
    }

    std::unique_ptr<Hasher> get_hasher_for(Algorithm algo) noexcept
    {
#if defined(_WIN32)
        return std::make_unique<BCryptHasher>(algo);
#else
        switch (algo)
        {
            case Algorithm::Sha1: return std::make_unique<ShaHasher<Sha1Algorithm>>();
            case Algorithm::Sha256: return std::make_unique<ShaHasher<Sha256Algorithm>>();
            case Algorithm::Sha512: return std::make_unique<ShaHasher<Sha512Algorithm>>();
            default: vcpkg::Checks::exit_with_message(VCPKG_LINE_INFO, "Unknown hashing algorithm: %s", algo);
        }
#endif
    }

    template<class F>
    static std::string do_hash(Algorithm algo, const F& f) noexcept
    {
#if defined(_WIN32)
        auto hasher = BCryptHasher(algo);
        return f(hasher);
#else
        switch (algo)
        {
            case Algorithm::Sha1:
            {
                auto hasher = ShaHasher<Sha1Algorithm>();
                return f(hasher);
            }
            case Algorithm::Sha256:
            {
                auto hasher = ShaHasher<Sha256Algorithm>();
                return f(hasher);
            }
            case Algorithm::Sha512:
            {
                auto hasher = ShaHasher<Sha512Algorithm>();
                return f(hasher);
            }
            default: vcpkg::Checks::exit_with_message(VCPKG_LINE_INFO, "Unknown hashing algorithm: %s", algo);
        }
#endif
    }

    std::string get_bytes_hash(const void* first, const void* last, Algorithm algo) noexcept
    {
        return do_hash(algo, [first, last](Hasher& hasher) {
            hasher.add_bytes(first, last);
            return hasher.get_hash();
        });
    }

    std::string get_string_hash(StringView sv, Algorithm algo) noexcept
    {
        return get_bytes_hash(sv.data(), sv.data() + sv.size(), algo);
    }

    // TODO: use Files::Filesystem to open a file
    std::string get_file_hash(const Files::Filesystem&,
                              const fs::path& path,
                              Algorithm algo,
                              std::error_code& ec) noexcept
    {
        auto file = std::fstream(path.c_str(), std::ios_base::in | std::ios_base::binary);
        if (!file)
        {
            ec.assign(ENOENT, std::system_category());
            return {};
        }

        return do_hash(algo, [&file, &ec](Hasher& hasher) {
            constexpr std::size_t buffer_size = 1024 * 32;
            auto buffer = std::make_unique<char[]>(buffer_size);
            for (;;)
            {
                file.read(buffer.get(), buffer_size);
                if (file.eof())
                {
                    hasher.add_bytes(buffer.get(), buffer.get() + file.gcount());
                    return hasher.get_hash();
                }
                else if (file)
                {
                    hasher.add_bytes(buffer.get(), buffer.get() + buffer_size);
                }
                else
                {
                    ec = std::io_errc::stream;
                    return std::string();
                }
            }
        });
    }
}
