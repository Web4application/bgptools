#include "crypto_base64.h"
#include <string.h>
#include <stdlib.h>

static const char b64_table[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    "abcdefghijklmnopqrstuvwxyz"
    "0123456789+/";

static const char b64_url_table[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    "abcdefghijklmnopqrstuvwxyz"
    "0123456789-_";

size_t base64_encoded_size(size_t input_len) {
    return ((input_len + 2) / 3) * 4;
}

int base64_encode(const uint8_t *input, size_t input_len, char *output, size_t output_size) {
    size_t enc_len = base64_encoded_size(input_len);

    if (output_size < enc_len + 1) {
        return -1;
    }

    size_t i, j;
    for (i = 0, j = 0; i < input_len;) {

        uint32_t octet_a = i < input_len ? input[i++] : 0;
        uint32_t octet_b = i < input_len ? input[i++] : 0;
        uint32_t octet_c = i < input_len ? input[i++] : 0;

        uint32_t triple = (octet_a << 16) | (octet_b << 8) | octet_c;

        output[j++] = b64_table[(triple >> 18) & 0x3F];
        output[j++] = b64_table[(triple >> 12) & 0x3F];
        output[j++] = b64_table[(triple >> 6) & 0x3F];
        output[j++] = b64_table[triple & 0x3F];
    }

    // padding fix
    int mod = input_len % 3;
    if (mod) {
        output[enc_len - 1] = '=';
        if (mod == 1) output[enc_len - 2] = '=';
    }

    output[enc_len] = '\0';
    return 0;
}
