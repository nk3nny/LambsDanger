// Read the current contents of the mod.cpp
// file from the project source
let version = HEMTT_DIRECTORY
        .join("mod.cpp")
        .open_file()
        .read();
// Replace the placeholder version with the actual version
version.replace(`{version}`, HEMTT_PROJECT_VERSION);
// Write the new contents to the build output
// create_file will overwrite the file if it exists
HEMTT_OUTPUT
        .join("mod.cpp")
        .create_file()
        .write(version);