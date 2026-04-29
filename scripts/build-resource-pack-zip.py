import os
import zipfile

output_name = os.environ["PACK_ZIP_NAME"]
required = ["assets", "pack.mcmeta", "pack.png"]

for path in required:
    if not os.path.exists(path):
        raise FileNotFoundError(f"Required path missing: {path}")

with zipfile.ZipFile(output_name, "w", zipfile.ZIP_DEFLATED) as zf:
    for root, _, files in os.walk("assets"):
        for file in files:
            full_path = os.path.join(root, file)
            arcname = os.path.relpath(full_path, ".")
            zf.write(full_path, arcname)

    zf.write("pack.mcmeta", "pack.mcmeta")
    zf.write("pack.png", "pack.png")

print(f"Created {output_name}")
