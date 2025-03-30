# Generic-Launch-Scripts

This repository contains a collection of generic launch scripts designed to simplify running applications with specific configurations.

## Scripts

* **`sarekrun`**:
    * Applies the Proton-Sarek agg profile settings to the specified program. This allows you to use this settings outside of the Proton-Sarek, without manual environment variable configuration.
* **`softwarerun`**:
    * Forces the specified program to run in software rendering mode.
    * **Note:** You may need to modify the `softwarerun` file in case the default target for VK_ICD_FILENAMES is not the desired one, or it uses an incorrect path. The default path and target should work for most installations.
* **`glthread`**:
    * Enables OpenGL thread optimizations for the selected program, might increase or decrease the fps.
* **`skthrun`**:
	* Just like `sarekrun`, but with OpenGL thread optimizations, might increase or decrease the fps.
      
## Installation

1.  Download the scripts.
2.  Open a terminal and navigate to the directory where you downloaded the scripts.
3.  Copy the scripts to `/usr/local/bin` using the following command:

    ```bash
    sudo cp sarekrun softwarerun glthread skthrun /usr/local/bin/
    ```

    * Using `/usr/local/bin` instead of `/usr/bin` is recommended for locally installed executables to prevent potential conflicts with system-managed files.

## Usage

* **Direct Execution Examples:**

    ```bash
    sarekrun program_name
    glthread program_name
    softwarerun program_name
    sarekrun glthread softwarerun program_name
    skthrun program_name
    ```

    Replace `program_name` with the actual name or path of the program you want to run.

* **Launchers (Steam, Lutris, etc.) Examples:**

    In the launch parameters on the game that you want to launch in your launcher, add:

    ```
    sarekrun
    glthread
    softwarerun
    sarekrun glthread softwarerun
    skthrun
    ```

    * On Steam remember to add at the end `%command%`.

## Notes

* These scripts are designed for Linux based systems.
* It is recomended to use /usr/local/bin, to avoid problems with system files.

## Contributing

Feel free to contribute improvements or new generic launch scripts to this repository.
