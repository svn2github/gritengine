#include <cstdlib>
#include <iostream>

#include <unicode/unistr.h>
#include <unicode/regex.h>

static std::string to_utf8 (const UnicodeString &ustr) {
        struct Sink : public ByteSink {
                std::string str;
                virtual void Append (const char* bytes, int32_t n) {
                        str.append(bytes, n);
                }
        };
        Sink sink;
        ustr.toUTF8(sink);
        return sink.str;
}

int main(void)
{
        long init = 0;
        UnicodeString haystack = "hello world";
        UnicodeString needle = ".";

        UErrorCode status = U_ZERO_ERROR;

        RegexMatcher matcher(needle, 0, status);
        if (U_FAILURE(status)) {
                std::cerr << "Syntax error in regex: \"" << to_utf8(needle) << "\": " << u_errorName(status) << std::endl;
                return EXIT_FAILURE;
        }

        matcher.reset(haystack);
        matcher.reset(init, status);
        if (U_FAILURE(status)) {
                std::cerr <<  u_errorName(status) << std::endl;
                return EXIT_FAILURE;
        }

        status = U_ZERO_ERROR;
        if (matcher.find()) {
                long matches = matcher.groupCount();
                if (matches == 0) {
                        UnicodeString match = matcher.group(status);
                        if (U_FAILURE(status)) {
                                std::cerr << u_errorName(status) << std::endl;
                                return EXIT_FAILURE;
                        }
                        std::cout << "match: " << to_utf8(match) << std::endl;
                        std::cout << "matches: " << 1 << std::endl;
                } else {
                        for (long i=1 ; i<=matches ; ++i) {
                                UnicodeString match = matcher.group(i, status);
                                if (U_FAILURE(status)) {
                                        std::cerr <<  u_errorName(status) << std::endl;
                                        return EXIT_FAILURE;
                                }
                                std::cout << "match: " << to_utf8(match) << std::endl;
                        }
                        std::cout << "matches: " << matches << std::endl;
                }
        } else {
                std::cout << "match: nil" << std::endl;
                std::cout << "matches: " << 1 << std::endl;
        }

        return EXIT_SUCCESS;
}

// vim: shiftwidth=8:tabstop=8:expandtab

