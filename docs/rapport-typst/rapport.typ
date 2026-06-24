#import "uqac.typ": rapport

#show: rapport.with(
  titre: "Chiffrement homomorphe basé sur LWE",
  sous-titre: "Implémentation logicielle et analyse d'impact de la gestion de l'erreur",
  matiere: "8INF874 --- Cryptographie",
  departement: "Département d'informatique et de mathématique",
  professeur: "Florentin Thullier",
  equipe: (
    (nom: "Bossard", prenom: "Justin", code: "BOSJ08070300"),
    (nom: "Plet", prenom: "Samuel", code: "PLES07110100"),
  ),
  date: "22 juin 2026",
  trimestre: "Trimestre d'été",
  logo: "logo-uqac.pdf",
  table-des-matieres: true,
)

#include("01_introduction.typ")
#include("02_theorie.typ")
#include("03_archi.typ")
#include("04_analyses.typ")
#include("05_conclusion.typ")

#pagebreak()
= Annexes

== Backend C++

Pour compiler : ```bash cmake -B build && cmake --build build```.

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <cmath>
#include <iomanip>
#include <sstream>
#include <algorithm>
#include <chrono>
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
    int gamma_degree = std::stoi(argv[3]); 
    std::string output_path = argv[4];
    std::string server_view_path = argv[5];

    if (gamma_degree < 1) gamma_degree = 1;

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
    parms.set_plain_modulus(PlainModulus::Batching(poly_modulus_degree, 45));

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

    // --- CLIENT : Chiffrement ---
    std::vector<uint64_t> image_vector(poly_modulus_degree, 0ULL);
    for (size_t i = 0; i < pixel_count; i++) image_vector[i] = img_data[i];

    Plaintext plain_image;
    batch_encoder.encode(image_vector, plain_image);
    Ciphertext encrypted_image;
    encryptor.encrypt(plain_image, encrypted_image);

    // --- SERVEUR : 1. Évaluation Polynomiale (Correction Gamma) ---
    Ciphertext encrypted_result = encrypted_image;
    uint64_t scale_factor = static_cast<uint64_t>(std::pow(255.0, gamma_degree - 1));

    long long time_mult_ms = 0;
    auto start_mult = std::chrono::high_resolution_clock::now();
    
    for (int it = 1; it < gamma_degree; ++it) {
        evaluator.multiply_inplace(encrypted_result, encrypted_image);
        evaluator.relinearize_inplace(encrypted_result, relin_keys);
    }
    
    auto end_mult = std::chrono::high_resolution_clock::now();
    if (gamma_degree > 1) {
        time_mult_ms = std::chrono::duration_cast<std::chrono::milliseconds>(end_mult - start_mult).count();
    }

    // --- SERVEUR : 2. Addition Linéaire (Luminosité avec mise à l'échelle) ---
    long long time_add_us = 0;
    if (brightness != 0) {
        int64_t scaled_brightness = static_cast<int64_t>(brightness) * scale_factor;
        std::vector<uint64_t> vec_B(poly_modulus_degree, std::abs(scaled_brightness));
        Plaintext plain_B;
        batch_encoder.encode(vec_B, plain_B);
        
        auto start_add = std::chrono::high_resolution_clock::now();
        if (scaled_brightness > 0) evaluator.add_plain_inplace(encrypted_result, plain_B);
        else evaluator.sub_plain_inplace(encrypted_result, plain_B);
        auto end_add = std::chrono::high_resolution_clock::now();
        
        time_add_us = std::chrono::duration_cast<std::chrono::microseconds>(end_add - start_add).count();
    }

    // Extraction de la vue serveur
    std::vector<unsigned char> server_pixels(pixel_count);
    const uint64_t* cipher_data = encrypted_result.data(0);
    for (size_t i = 0; i < pixel_count; i++) {
        server_pixels[i] = static_cast<unsigned char>(cipher_data[i] % 256);
    }
    stbi_write_png(server_view_path.c_str(), width, height, 1, server_pixels.data(), width);

    // --- CLIENT : Déchiffrement et Validation ---
    Plaintext plain_result;
    decryptor.decrypt(encrypted_result, plain_result);
    std::vector<uint64_t> decoded_result;
    batch_encoder.decode(plain_result, decoded_result);

    std::vector<unsigned char> final_pixels(pixel_count);
    double total_diff = 0.0;
    uint64_t plain_mod = parms.plain_modulus().value();

    for (size_t i = 0; i < pixel_count; i++) {
        uint64_t val = decoded_result[i];
        int64_t actual_val = val > (plain_mod / 2) ? val - plain_mod : val;
        
        // Division par le facteur d'échelle
        double pixel_val = static_cast<double>(actual_val) / scale_factor;
        final_pixels[i] = static_cast<unsigned char>(std::clamp(static_cast<int>(std::round(pixel_val)), 0, 255));

        // Vérité terrain
        double expected_pixel = std::pow(static_cast<double>(img_data[i]), gamma_degree) / scale_factor + brightness;
        int expected = std::clamp(static_cast<int>(std::round(expected_pixel)), 0, 255);
        
        total_diff += std::abs(static_cast<int>(final_pixels[i]) - expected);
    }
    
    stbi_image_free(img_data);
    stbi_write_png(output_path.c_str(), width, height, 1, final_pixels.data(), width);

    std::cout << "{\n"
              << "  \"budget_final\": " << decryptor.invariant_noise_budget(encrypted_result) << ",\n"
              << "  \"ecart_moyen\": " << std::fixed << std::setprecision(4) << (total_diff / pixel_count) << ",\n"
              << "  \"hash_src\": \"" << src_hash << "\",\n"
              << "  \"hash_final\": \"" << compute_hash(final_pixels) << "\",\n"
              << "  \"taille_octets\": " << encrypted_result.save_size() << ",\n"
              << "  \"temps_mult_ms\": " << time_mult_ms << ",\n"
              << "  \"temps_add_us\": " << time_add_us << "\n"
              << "}\n";

    return 0;
}
```

== Serveur python

Pour lancer le serveur : ```bash uv run server.py```.

```py
#!/usr/bin/env python3
# /// script
# dependencies = [
#     "flask",
#     "pillow",
# ]
# ///

from flask import Flask, request, jsonify, render_template_string
import subprocess
import json
import os
import time

app = Flask(__name__)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Démonstration FHE</title>
    <style>
        body { font-family: system-ui, sans-serif; margin: 0; background: #eceff1; color: #333; }
        .container { display: flex; width: 100vw; min-height: 100vh; }
        .column { flex: 1; padding: 30px; display: flex; flex-direction: column; gap: 20px; }
        .client-side { background: #f8f9fa; border-right: 4px solid #cfd8dc; }
        .server-side { background: #e0e0e0; }
        .card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .img-container { display: flex; gap: 20px; align-items: flex-start; justify-content: center; }
        .img-box { text-align: center; }
        img { max-width: 100%; image-rendering: pixelated; border: 1px solid #aaa; background: #fff; }
        .controls { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
        button { grid-column: span 2; padding: 10px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        button:hover { background: #0056b3; }
        .metric { font-family: monospace; font-size: 13px; color: #555; background: #eee; padding: 8px; border-radius: 4px; text-align: left; margin-top: 10px;}
        h2 { margin-top: 0; color: #263238; border-bottom: 2px solid #ccc; padding-bottom: 10px; }
    </style>
</head>
<body>
    <div class="container">
        
        <div class="column client-side">
            <h2>Vue Client (Possède la clé privée)</h2>
            
            <div class="card">
                <h3>Paramètres d'opération</h3>
                <div class="controls">
                    <div>
                        <label>Luminosité (Addition) : <span id="val_b">0</span></label><br>
                        <input type="range" id="brightness" min="-100" max="100" value="0" oninput="document.getElementById('val_b').innerText = this.value" style="width:100%">
                        <small>Consommation de bruit nulle.</small>
                    </div>
                    <div>
                        <label>Degré Gamma (Multiplication) : <span id="val_c">1</span></label><br>
                        <input type="range" id="gamma_degree" min="1" max="5" value="1" oninput="document.getElementById('val_c').innerText = this.value" style="width:100%">
                        <small>1 = Neutre (x¹). Valeurs > 1 accumulent du bruit (x², x³).</small>
                    </div>
                    <button onclick="applyFilter()">Exécuter</button>
                </div>
            </div>

            <div class="card img-container">
                <div class="img-box">
                    <h3>Source</h3>
                    <img src="/static/input.png" alt="Source">
                    <div class="metric">
                        Hash: <strong id="hash_src">-</strong>
                    </div>
                </div>
                <div class="img-box">
                    <h3>Résultat Déchiffré</h3>
                    <img id="resultImage" src="" alt="En attente...">
                    <div class="metric">
                        Hash: <strong id="hash_final">-</strong><br>
                        Écart d'erreur: <strong id="ecart" style="color:red">-</strong>
                    </div>
                </div>
            </div>
        </div>

        <div class="column server-side">
            <h2>Vue Serveur (Environnement Aveugle)</h2>
            
            <div class="card img-container">
                <div class="img-box">
                    <h3>Données manipulées</h3>
                    <img id="serverImage" src="" alt="En attente...">
                    <div class="metric">
                        Taille en mémoire: <strong id="cipher_size">-</strong> octets
                    </div>
                </div>
            </div>

            <div class="card">
                <h3>État du texte chiffré</h3>
                <p>Budget de bruit restant : <strong id="budget">-</strong> bits</p>
                <div class="metric">
                    Temps d'addition : <strong id="time_add">-</strong> µs<br>
                    Temps de multiplication : <strong id="time_mult">-</strong> ms
                </div>
            </div>
        </div>
        
    </div>

    <script>
        function applyFilter() {
            let b = document.getElementById('brightness').value;
            let c = document.getElementById('gamma_degree').value;
            
            fetch('/process', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({brightness: b, gamma_degree: c})
            })
            .then(r => r.json())
            .then(data => {
                if(data.error) return alert(data.error);
                
                document.getElementById('resultImage').src = '/' + data.out_img;
                document.getElementById('serverImage').src = '/' + data.srv_img;
                
                document.getElementById('cipher_size').innerText = data.taille_octets;
                document.getElementById('budget').innerText = data.budget_final;
                document.getElementById('time_add').innerText = data.temps_add_us || 0;
                document.getElementById('time_mult').innerText = data.temps_mult_ms || 0;
                
                document.getElementById('hash_src').innerText = data.hash_src;
                document.getElementById('hash_final').innerText = data.hash_final;
                document.getElementById('ecart').innerText = data.ecart_moyen;
            });
        }
    </script>
</body>
</html>
"""

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/process', methods=['POST'])
def process():
    data = request.json
    brightness = data.get('brightness', 0)
    gamma_degree = data.get('gamma_degree', 1)
    
    ts = int(time.time() * 1000)
    out_file = f"static/out_{ts}.png"
    srv_file = f"static/srv_{ts}.png"
    
    result = subprocess.run(
        [
            "./build/main", 
            "static/input.png", 
            str(brightness), 
            str(gamma_degree), 
            out_file, 
            srv_file
        ],
        capture_output=True, text=True
    )
    
    try:
        parsed = json.loads(result.stdout)
        parsed["out_img"] = out_file
        parsed["srv_img"] = srv_file
        return jsonify(parsed)
    except json.JSONDecodeError:
        return jsonify({"error": "Erreur d'exécution C++", "details": result.stderr}), 500

if __name__ == '__main__':
    os.makedirs("static", exist_ok=True)
    if not os.path.exists("static/input.png"):
        from PIL import Image
        Image.new('L', (80, 80), color=128).save("static/input.png")
    app.run(port=5000, debug=False)
```

#pagebreak()
#bibliography(
  "refs.bib",
  style: "apa",
  title: "Références"
)
