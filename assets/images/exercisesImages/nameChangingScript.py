import os
import shutil

# Definiamo i percorsi
# '.' indica la cartella corrente dove si trova lo script
source_folder = '.' 
destination_folder = 'imagesExercises_2'

# Crea la cartella di destinazione se non esiste già
if not os.path.exists(destination_folder):
    os.makedirs(destination_folder)
    print(f"Cartella '{destination_folder}' creata con successo.")

# Recupera la lista di tutti i file nella cartella sorgente
files = os.listdir(source_folder)

moved_count = 0

print("Inizio spostamento file...")

for file_name in files:
    # Filtra i file che finiscono esattamente con '-2.webp'
    if file_name.endswith('-2.webp'):
        source_path = os.path.join(source_folder, file_name)
        destination_path = os.path.join(destination_folder, file_name)
        
        # Sposta il file dalla sorgente alla destinazione
        try:
            shutil.move(source_path, destination_path)
            print(f"Spostato: {file_name}")
            moved_count += 1
        except Exception as e:
            print(f"Errore nello spostamento di {file_name}: {e}")

print(f"\nOperazione completata!")
print(f"Totale file spostati in '{destination_folder}': {moved_count}")