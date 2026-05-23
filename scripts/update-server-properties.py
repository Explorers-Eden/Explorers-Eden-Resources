import os
import paramiko


def update_server_properties():
    host = os.environ["SFTP_HOST"]
    port = int(os.environ.get("SFTP_PORT", "22"))
    user = os.environ["SFTP_USER"]
    password = os.environ["SFTP_PASS"]
    remote_path = os.environ["REMOTE_SERVER_PROPERTIES"]
    local_path = "server.properties"
    resource_pack_url = os.environ["RESOURCE_PACK_URL"]
    resource_pack_sha1 = os.environ["RESOURCE_PACK_SHA1"]

    transport = paramiko.Transport((host, port))
    try:
        transport.connect(username=user, password=password)
        sftp = paramiko.SFTPClient.from_transport(transport)
        try:
            sftp.get(remote_path, local_path)
            print(f"Downloaded {remote_path}")
        finally:
            sftp.close()
    finally:
        transport.close()

    with open(local_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    found_pack = False
    found_sha1 = False
    new_lines = []

    for line in lines:
        if line.startswith("resource-pack="):
            new_lines.append(f"resource-pack={resource_pack_url}\n")
            found_pack = True
        elif line.startswith("resource-pack-sha1="):
            new_lines.append(f"resource-pack-sha1={resource_pack_sha1}\n")
            found_sha1 = True
        else:
            new_lines.append(line)

    if not found_pack:
        new_lines.append(f"resource-pack={resource_pack_url}\n")
    if not found_sha1:
        new_lines.append(f"resource-pack-sha1={resource_pack_sha1}\n")

    with open(local_path, "w", encoding="utf-8") as f:
        f.writelines(new_lines)

    print("Updated server.properties")


if __name__ == "__main__":
    update_server_properties()
