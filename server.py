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
    <title>Démonstration FHE - Masquage Spatial</title>
    <style>
        body { font-family: system-ui, sans-serif; margin: 0; background: #eceff1; color: #333; }
        .container { display: flex; width: 100vw; min-height: 100vh; }
        .column { flex: 1; padding: 30px; display: flex; flex-direction: column; gap: 20px; }
        .client-side { background: #f8f9fa; border-right: 4px solid #cfd8dc; }
        .server-side { background: #e0e0e0; }
        .card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .img-container { display: flex; gap: 20px; align-items: flex-start; justify-content: center; }
        .img-box { text-align: center; }
        img { max-width: 150px; image-rendering: pixelated; border: 1px solid #aaa; background: #fff; }
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
                        <label>Filtre (Addition) : <span id="val_b">0</span></label><br>
                        <input type="range" id="brightness" min="-100" max="100" value="0" oninput="document.getElementById('val_b').innerText = this.value" style="width:100%">
                        <small>Ne consomme pas de bruit.</small>
                    </div>
                    <div>
                        <label>Masquage (Multiplication) : <span id="val_i">0</span> itérations</label><br>
                        <input type="range" id="mask_iters" min="0" max="6" value="0" oninput="document.getElementById('val_i').innerText = this.value" style="width:100%">
                        <small>Multiplication par masque chiffré. Consomme ~30 bits/itération.</small>
                    </div>
                    <button onclick="applyFilter()">Exécuter</button>
                </div>
            </div>

            <div class="card img-container">
                <div class="img-box">
                    <h3>Source</h3>
                    <img src="/static/input.jpg" alt="Source">
                    <div class="metric">
                        Hash: <strong id="hash_src">-</strong>
                    </div>
                </div>
                <div class="img-box">
                    <h3>Résultat Déchiffré</h3>
                    <img id="resultImage" src="/static/input.jpg" alt="Résultat">
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
                    <img id="serverImage" src="/static/input.jpg" style="filter: blur(4px) grayscale(100%); opacity: 0.5;">
                    <div class="metric">
                        Taille en mémoire: <strong id="cipher_size">-</strong> octets
                    </div>
                </div>
            </div>

            <div class="card">
                <h3>État du texte chiffré</h3>
                <p>Budget de bruit initial : <strong>146 bits</strong></p>
                <p>Budget de bruit restant : <strong id="budget">-</strong> bits</p>
            </div>
        </div>
        
    </div>

    <script>
        function applyFilter() {
            let b = document.getElementById('brightness').value;
            let n = document.getElementById('mask_iters').value;
            
            fetch('/process', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({brightness: b, mask_iters: n})
            })
            .then(r => r.json())
            .then(data => {
                if(data.error) return alert(data.error);
                
                document.getElementById('resultImage').src = '/' + data.out_img;
                document.getElementById('serverImage').src = '/' + data.srv_img;
                document.getElementById('serverImage').style = ""; 
                
                document.getElementById('cipher_size').innerText = data.taille_octets;
                document.getElementById('budget').innerText = data.budget_final;
                
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
    mask_iters = data.get('mask_iters', 0)
    
    ts = int(time.time() * 1000)
    out_file = f"static/out_{ts}.png"
    srv_file = f"static/srv_{ts}.png"
    
    result = subprocess.run(
        [
            "./build/main", 
            "static/input.jpg", 
            str(brightness), 
            str(mask_iters), 
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
    if not os.path.exists("static/input.jpg"):
        from PIL import Image
        Image.new('L', (80, 80), color=128).save("static/input.jpg")
    app.run(port=5000, debug=False)
