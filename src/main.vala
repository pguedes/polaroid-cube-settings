using PolaroidCube.Model;
using PolaroidCube.IO;
using Gtk;
using PolaroidCube.UI;

namespace PolaroidCube {

    public errordomain PolaroidCubeError { CUBE_NOT_MOUNTED, DRIVE_NOT_FOUND }

	public class Main {

	    public static int main(string[] args) {
	        Gtk.init(ref args);

            try {
	            //File cube_root = find_polaroid_cube_root();
	            File cube_root = File.new_for_path("resources");
	            stdout.printf("cube path is %s\n", cube_root.get_path());

	            SettingsReader settings_reader = new SettingsReader();
	            var settings = settings_reader.read(cube_root);

                var window = new SettingsGUI(settings);
                window.show();

                window.save_settings.connect((settings) => {
                    try {
                        new SettingsWriter().write(cube_root, settings);
                    } catch (Error e) {
                        stderr.printf("Failed to initialize UI: %s\n", e.message);
                    }
                    stdout.printf("settings: %s\n", settings.to_string());
                } );

                Gtk.main();
            } catch (Error e) {
                stderr.printf("Failed to initialize UI: %s\n", e.message);
                return 1;
            }
            return 0;
	    }

        /**
        * Find the path for the root of the Polaroid CUBE file system
        *
        * This needs the following:
        *  - the Cube is a connected GLib.Drive with the name Polaroid CUBE
        *  - the Cube drive has one Glib.Volume
        *  - the Cube volume is mounted
        */
	    public static File find_polaroid_cube_root() throws PolaroidCubeError {

            VolumeMonitor monitor = VolumeMonitor.get();

            Drive cube_drive = find_polaroid_cube_drive(monitor.get_connected_drives());

            Volume cube_volume = cube_drive.get_volumes().nth(0).data;

            Mount? mount = cube_volume.get_mount();
            if (mount == null) {
                throw new PolaroidCubeError.CUBE_NOT_MOUNTED("The Polaroid CUBE drive is not mounted");
            }

            return mount.get_root();
	    }

        /**
        * Find the cube drive on a list of connected drives
        */
	    public static Drive find_polaroid_cube_drive(List<Drive> connectedDrives) throws PolaroidCubeError {

	        foreach(Drive drive in connectedDrives) {
	            if (drive.get_name() == "Polaroid CUBE") {
	                return drive;
	            }
	        }
	        throw new PolaroidCubeError.DRIVE_NOT_FOUND("Polaroid CUBE drive not found");
	    }
	}
}