import hashlib
import os

filename = os.environ["PACK_ZIP_NAME"]
sha1 = hashlib.sha1()

with open(filename, "rb") as f:
    for chunk in iter(lambda: f.read(8192), b""):
        sha1.update(chunk)

digest = sha1.hexdigest()

with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as out:
    out.write(f"sha1={digest}\n")

print(digest)
