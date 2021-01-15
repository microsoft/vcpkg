#pragma once

#include <vcpkg/base/files.h>

#include <string>

namespace vcpkg
{
    enum class DigestAlgorithm
    {
        Sha1,
        Sha256,
        Sha512,
    };

    const char* to_string(DigestAlgorithm algo) noexcept;
    Optional<DigestAlgorithm> digest_algorithm_from_string(StringView sv) noexcept;

    struct DigestHasher
    {
        virtual void add_bytes(const void* start, const void* end) noexcept = 0;

        // one may only call this once before calling `clear()` or the dtor
        virtual std::string get_hash() noexcept = 0;
        virtual void clear() noexcept = 0;
        virtual ~DigestHasher() = default;
    };

    std::unique_ptr<DigestHasher> get_hasher_for(DigestAlgorithm algo) noexcept;

    std::string get_bytes_digest(const void* first, const void* last, DigestAlgorithm algo) noexcept;
    std::string get_string_digest(StringView s, DigestAlgorithm algo) noexcept;
    std::string get_file_digest(const Files::Filesystem& fs,
                                const fs::path& path,
                                DigestAlgorithm algo,
                                std::error_code& ec) noexcept;
    inline std::string get_file_digest(LineInfo li,
                                       const Files::Filesystem& fs,
                                       const fs::path& path,
                                       DigestAlgorithm algo) noexcept
    {
        std::error_code ec;
        const auto result = get_file_digest(fs, path, algo, ec);
        if (ec)
        {
            Checks::exit_with_message(
                li, "Failure to read file '%s' for hashing: %s", fs::u8string(path), ec.message());
        }

        return result;
    }
}
