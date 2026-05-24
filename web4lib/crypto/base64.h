#ifndef CRYPTO_BASE64_H
#define CRYPTO_BASE64_H

#include <stddef.h>
#include <stdint.h>

int base64_encode(
    const uint8_t *input,
    size_t input_len,
    char *output,
    size_t output_size
);

int base64_decode(
    const char *input,
    uint8_t *output,
    size_t output_size
);

size_t base64_encoded_size(size_t input_len);
size_t base64_decoded_size(const char *input);

#endif
