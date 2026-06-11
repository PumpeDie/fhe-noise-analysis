#include <iostream>
#include <vector>
#include <chrono>
#include <seal/seal.h>

using namespace seal;
using namespace std::chrono;

int main() {
    // 1. Configuration
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
    
    GaloisKeys galois_keys;
    keygen.create_galois_keys(galois_keys);

    // Ajout : Clés de relinéarisation nécessaires pour limiter la taille du 
    // texte chiffré lors des multiplications successives
    RelinKeys relin_keys;
    keygen.create_relin_keys(relin_keys);

    Encryptor encryptor(context, public_key);
    Evaluator evaluator(context);
    Decryptor decryptor(context, secret_key);
    BatchEncoder batch_encoder(context);

    size_t slot_count = batch_encoder.slot_count();

    // 2. Préparation et chiffrement
    std::vector<uint64_t> input_vector(slot_count, 0ULL);
    for (size_t i = 0; i < 4; i++) {
        input_vector[i] = i + 2; 
    }

    Plaintext plain_input;
    batch_encoder.encode(input_vector, plain_input);
    Ciphertext encrypted_input;
    encryptor.encrypt(plain_input, encrypted_input);

    // --- ÉVALUATION DE L'EMPREINTE MÉMOIRE ---
    std::cout << "--- Empreinte mémoire (octets) ---\n";
    std::cout << "Clé publique         : " << public_key.save_size() << "\n";
    std::cout << "Clé secrète          : " << secret_key.save_size() << "\n";
    std::cout << "Clés de Galois       : " << galois_keys.save_size() << "\n";
    std::cout << "Clés de Relin        : " << relin_keys.save_size() << "\n";
    std::cout << "Texte chiffré (init) : " << encrypted_input.save_size() << "\n\n";

    // --- ÉPUISEMENT DU BUDGET DE BRUIT ---
    std::cout << "--- Test d'épuisement du bruit ---\n";
    Ciphertext noise_test_cipher = encrypted_input;
    int iteration = 0;
    
    std::cout << "Budget initial : " << decryptor.invariant_noise_budget(noise_test_cipher) << " bits\n";

    // Boucle de multiplication jusqu'à épuisement du budget
    while (decryptor.invariant_noise_budget(noise_test_cipher) > 0) {
        iteration++;
        
        // Élévation au carré pour faire croître le bruit rapidement
        evaluator.square_inplace(noise_test_cipher);
        
        // Relinéarisation pour ramener le texte chiffré à sa taille d'origine (2 polynômes)
        evaluator.relinearize_inplace(noise_test_cipher, relin_keys);
        
        int current_budget = decryptor.invariant_noise_budget(noise_test_cipher);
        std::cout << "Itération " << iteration << " | Budget restant : " 
                  << current_budget << " bits\n";
        
        // Sécurité pour éviter une boucle infinie en cas de configuration anormale
        if (iteration > 20) break; 
    }

    std::cout << "\nBudget épuisé après " << iteration << " multiplications successives.\n";

    // Vérification de l'échec du déchiffrement
    Plaintext failed_plain;
    decryptor.decrypt(noise_test_cipher, failed_plain);
    std::vector<uint64_t> failed_decoded;
    batch_encoder.decode(failed_plain, failed_decoded);
    
    std::cout << "Test de déchiffrement après épuisement (valeur corrompue attendue) : " 
              << failed_decoded[0] << "\n";

    return 0;
}
