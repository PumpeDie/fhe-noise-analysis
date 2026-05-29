#include <iostream>
#include <seal/seal.h>

using namespace std;
using namespace seal;

int main() {
    cout << "--- Initializing SEAL context (BFV scheme) ---" << endl;
    
    // 1. LWE parameter setup
    EncryptionParameters parms(scheme_type::bfv);
    size_t poly_modulus_degree = 8192;
    parms.set_poly_modulus_degree(poly_modulus_degree);
    parms.set_coeff_modulus(CoeffModulus::BFVDefault(poly_modulus_degree));
    parms.set_plain_modulus(PlainModulus::Batching(poly_modulus_degree, 20));
    
    SEALContext context(parms);
    
    // 2. Key generation
    KeyGenerator keygen(context);
    SecretKey secret_key = keygen.secret_key();
    PublicKey public_key;
    keygen.create_public_key(public_key);
    
    // 3. Module initialization
    Encryptor encryptor(context, public_key);
    Evaluator evaluator(context);
    Decryptor decryptor(context, secret_key);
    
    // 4. Encryption and noise inspection
    Plaintext plain("5"); // Encrypt the integer 5
    Ciphertext encrypted;
    
    cout << "Encrypting value: " << plain.to_string() << endl;
    encryptor.encrypt(plain, encrypted);
    
    // The key metric for your impact analysis
    int noise_budget = decryptor.invariant_noise_budget(encrypted);
    cout << "Initial noise budget: " << noise_budget << " bits" << endl;
    
    return 0;
}