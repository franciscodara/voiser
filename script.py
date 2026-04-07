import os

base_dir = "/home/dara/dev/finwise/lib"

core_dirs = ["constants", "errors", "extensions", "network", "router", "services", "theme", "widgets"]
features = ["auth", "expenses", "income", "dashboard", "categories", "settings"]
feature_layers = ["data", "domain", "presentation"]

# Create core dirs
for d in core_dirs:
    path = os.path.join(base_dir, "core", d)
    os.makedirs(path, exist_ok=True)
    # create a dummy file
    filename = f"{d}_example.dart"
    with open(os.path.join(path, filename), "w") as f:
        f.write(f"// Arquivo de contexto para a pasta core/{d}\n")

# Create features dirs
for f_name in features:
    for layer in feature_layers:
        path = os.path.join(base_dir, "features", f_name, layer)
        os.makedirs(path, exist_ok=True)
        # create a dummy file
        filename = f"{f_name}_{layer}_example.dart"
        with open(os.path.join(path, filename), "w") as f:
            f.write(f"// Arquivo de contexto para a pasta features/{f_name}/{layer}\n")

print("Folders and context files created.")
