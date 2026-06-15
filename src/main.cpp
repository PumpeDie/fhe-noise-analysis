#include <iostream>
#include <vector>
#include <string>
#include <cmath>
#include <iomanip>
#include <sstream>
#include <seal/seal.h>
#include "stb_image.h"
#include "stb_image_write.h"

using namespace seal;

std::string compute_hash(const std::vector<unsigned char>& data) {
    unsigned long hash = 5381;
    for (unsigned char c : data) hash = ((hash << 5) + hash) + c;
    std::stringstream ss;
    ss << std::hex << hash;
    return ss.str();
}

int main(int argc, char* argv[]) {
    if (argc < 6) return 1;

    std::string input_path = argv[1];
    int brightness = std::stoi(argv[2]);
    int mask_iters = std::stoi(argv[3]);
    std::string output_path = argv[4];
    std::string server_view_path = argv[5];

    int width, height, channels;
    unsigned char *img_data = stbi_load(input_path.c_str(), &width, &height, &channels, 1);
    if (!img_data) return 1;
    size_t pixel_count = width * height;

    std::vector<unsigned char> src_pixels(img_data, img_data + pixel_count);
    std::string src_hash = compute_hash(src_pixels);

    EncryptionParameters parms(scheme_type::bfv);
    size_t poly_modulus_degree = 8192;
    parms.set_poly_modulus_degree(poly_modulus_degree);
    parms.set_coeff_modulus(CoeffModulus::BFVDefault(poly_modulus_degree));
    parms.set_plain_modulus(PlainModulus::Batching(poly_modulus_degree, 20));

    SEALContext context(parms);
    KeyGenerator keygen(context);
    SecretKey secret_key = keygen.secret_key();
    PublicKey public_key;
    keygen.create_public_key(public_key);
    RelinKeys relin_keys;
    keygen.create_relin_keys(relin_keys);

    Encryptor encryptor(context, public_key);
    Evaluator evaluator(context);
    Decryptor decryptor(context, secret_key);
    BatchEncoder batch_encoder(context);

    // --- CLIENT : Chiffrement de l'image ---
    std::vector<uint64_t> image_vector(poly_modulus_degree, 0ULL);
    for (size_t i = 0; i < pixel_count; i++) image_vector[i] = img_data[i];

    Plaintext plain_image;
    batch_encoder.encode(image_vector, plain_image);
    Ciphertext encrypted_image;
    encryptor.encrypt(plain_image, encrypted_image);

    // --- SERVEUR : Opération d'Addition (Luminosité) ---
    if (brightness != 0) {
        std::vector<uint64_t> filter_vector(poly_modulus_degree, std::abs(brightness));
        Plaintext plain_filter;
        batch_encoder.encode(filter_vector, plain_filter);
        if (brightness > 0) evaluator.add_plain_inplace(encrypted_image, plain_filter);
        else evaluator.sub_plain_inplace(encrypted_image, plain_filter);
    }

    // --- SERVEUR : Opération de Multiplication (Masquage / Censure) ---
    std::vector<uint64_t> mask_vector(poly_modulus_degree, 0ULL);
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            // Conserve le carré central (50% de l'image)
            if (x >= width/4 && x < 3*width/4 && y >= height/4 && y < 3*height/4) {
                mask_vector[y * width + x] = 1ULL;
            } else {
                mask_vector[y * width + x] = 0ULL;
            }
        }
    }

    Plaintext plain_mask;
    batch_encoder.encode(mask_vector, plain_mask);
    Ciphertext encrypted_mask;
    encryptor.encrypt(plain_mask, encrypted_mask);

    for (int it = 0; it < mask_iters; ++it) {
        evaluator.multiply_inplace(encrypted_image, encrypted_mask);
        evaluator.relinearize_inplace(encrypted_image, relin_keys);
    }

    // Vue serveur (Extraction des octets de bruit)
    std::vector<unsigned char> server_pixels(pixel_count);
    const uint64_t* cipher_data = encrypted_image.data(0);
    for (size_t i = 0; i < pixel_count; i++) {
        server_pixels[i] = static_cast<unsigned char>(cipher_data[i] % 256);
    }
    stbi_write_png(server_view_path.c_str(), width, height, 1, server_pixels.data(), width);

    // --- CLIENT : Déchiffrement et Validation ---
    Plaintext plain_result;
    decryptor.decrypt(encrypted_image, plain_result);
    std::vector<uint64_t> decoded_result;
    batch_encoder.decode(plain_result, decoded_result);

    std::vector<unsigned char> final_pixels(pixel_count);
    double total_diff = 0.0;
    uint64_t plain_mod = parms.plain_modulus().value();

    for (size_t i = 0; i < pixel_count; i++) {
        uint64_t val = decoded_result[i];
        int64_t actual_val = val > (plain_mod / 2) ? val - plain_mod : val;
        final_pixels[i] = static_cast<unsigned char>(std::min<int64_t>(std::max<int64_t>(0, actual_val), 255));

        // Calcul de la vérité terrain avec application du masque
        int expected = std::min(std::max(0, static_cast<int>(img_data[i]) + brightness), 255);
        if (mask_iters > 0) {
            expected *= mask_vector[i];
        }
        total_diff += std::abs(static_cast<int>(final_pixels[i]) - expected);
    }
    
    stbi_image_free(img_data);
    stbi_write_png(output_path.c_str(), width, height, 1, final_pixels.data(), width);

    std::cout << "{\n"
              << "  \"budget_final\": " << decryptor.invariant_noise_budget(encrypted_image) << ",\n"
              << "  \"ecart_moyen\": " << std::fixed << std::setprecision(4) << (total_diff / pixel_count) << ",\n"
              << "  \"hash_src\": \"" << src_hash << "\",\n"
              << "  \"hash_final\": \"" << compute_hash(final_pixels) << "\",\n"
              << "  \"taille_octets\": " << encrypted_image.save_size() << "\n"
              << "}\n";

    return 0;
}
