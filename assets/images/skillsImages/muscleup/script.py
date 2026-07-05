import os
from PIL import Image

def convert_images_to_webp(directory_path="."):
    # Estensioni supportate da convertire
    valid_extensions = ('.png', '.jpg', '.jpeg')
    
    # Contatori per il resoconto finale
    converted_count = 0
    
    print(f"📁 Inizio scansione della cartella: {os.path.abspath(directory_path)}\n")
    
    # Cicla attraverso tutti i file presenti nella directory
    for filename in os.listdir(directory_path):
        if filename.lower().endswith(valid_extensions):
            file_path = os.path.join(directory_path, filename)
            
            # Separa il nome del file dall'estensione originale
            name_without_ext, _ = os.path.splitext(filename)
            webp_path = os.path.join(directory_path, f"{name_without_ext}.webp")
            
            try:
                # Apre l'immagine originale e la salva in formato webp
                with Image.open(file_path) as img:
                    # 'lossless=True' mantiene la massima qualità per i PNG, 
                    # oppure puoi usare 'quality=80' se vuoi comprimerle di più
                    img.save(webp_path, "WEBP", quality=85)
                
                print(f"✅ Convertito: {filename} ➔ {name_without_ext}.webp")
                
                # Rimuove il file originale (PNG/JPG) modificando la directory
                os.remove(file_path)
                converted_count += 1
                
            except Exception as e:
                print(f"❌ Errore durante la conversione di {filename}: {e}")

    print(f"\n🎉 Fine! Convertite ed eliminate {converted_count} immagini originali.")

if __name__ == "__main__":
    # Di default lavora nella cartella in cui si trova lo script (".")
    # Se vuoi usarlo su un'altra cartella, inserisci il percorso qui, es: convert_images_to_webp("C:/MioPercorso/Assets")
    convert_images_to_webp()