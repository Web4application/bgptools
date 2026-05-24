#include "crypto_base64.h"
#include <string.h>

static unsigned char dtable[256];

static void init_table() {
    memset(dtable, 0x80, 256);
    for (int i = 0; i < 64; i++) {
        dtable[(unsigned char)(
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"[i]
        )] = i;
    }
    dtable['='] = 0;
}

int base64_decode(const char *input, uint8_t *output, size_t output_size) {
    if (dtable['A'] == 0x80) init_table();

    size_t len = strlen(input);
    size_t i = 0, j = 0;

    while (i < len) {
        uint32_t sextet_a = dtable[(unsigned char)input[i++]];
        uint32_t sextet_b = dtable[(unsigned char)input[i++]];
        uint32_t sextet_c = dtable[(unsigned char)input[i++]];
        uint32_t sextet_d = dtable[(unsigned char)input[i++]];

        uint32_t triple =
            (sextet_a << 18) |
            (sextet_b << 12) |
            (sextet_c << 6) |
            sextet_d;

        if (j < output_size) output[j++] = (triple >> 16) & 0xFF;
        if (j < output_size) output[j++] = (triple >> 8) & 0xFF;
        if (j < output_size) output[j++] = triple & 0xFF;
    }

    return 0;
}
