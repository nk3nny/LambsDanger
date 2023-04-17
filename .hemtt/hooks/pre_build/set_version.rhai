// Get the path to the script_version.hpp file
let version = HEMTT_VFS
        .join("addons")
        .join("main")
        .join("script_version.hpp");
// Create (or overwrite) the file
let out = version.create_file();
out.write("#define MAJOR " + HEMTT_PROJECT_VERSION_MAJOR + "\n");
out.write("#define MINOR " + HEMTT_PROJECT_VERSION_MINOR + "\n");
out.write("#define PATCH " + HEMTT_PROJECT_VERSION_PATCH + "\n");
if HEMTT_PROJECT_VERSION_HASBUILD {
    out.write("#define BUILD " + HEMTT_PROJECT_VERSION_BUILD + "\n");
}
print("Set version to " + HEMTT_PROJECT_VERSION);