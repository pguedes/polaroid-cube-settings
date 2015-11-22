using PolaroidCube.Model;

namespace PolaroidCube.IO {

    errordomain SettingFormatError { VERSION_FORMAT }
    public errordomain PolaroidCubeFinderError { CUBE_NOT_MOUNTED, DRIVE_NOT_FOUND }

    private const string SETTINGS_FILE_NAME = "Setting.txt";
    private const string NEW_SETTINGS_FILE_NAME = "Setting.txt.new";
    private const string BKUP_SETTINGS_FILE_NAME = "Setting.txt.bkup";

    /**
    * This class implements the public I/O facade for the polaroid Cube.
    * You get an instance of it by calling the get method and you can then use it to read_settings or update_settings.
    */
    public class Cube {
        private SettingsReader settings_reader;
        private SettingsWriter settings_writer;

        private Cube(File root) {
            this.settings_reader = new SettingsReader(root);
            this.settings_writer = new SettingsWriter(root);
        }

        public CubeSettings read_settings() throws Error {
            return this.settings_reader.read();
        }

        public void update_settings(CubeSettings settings) throws Error {
            this.settings_writer.write(settings);
        }

        public static Cube get() throws PolaroidCubeFinderError {
            //File cube_root = File.new_for_path("resources");
            File root = find_polaroid_cube_root();
            debug("cube path is %s", root.get_path());
            return new Cube(root);
        }

        /**
        * Find the path for the root of the Polaroid CUBE file system
        *
        * This needs the following:
        *  - the Cube is a connected GLib.Drive with the name Polaroid CUBE
        *  - the Cube drive has one Glib.Volume
        *  - the Cube volume is mounted
        */
	    private static File find_polaroid_cube_root() throws PolaroidCubeFinderError {

            VolumeMonitor monitor = VolumeMonitor.get();

            Drive cube_drive = find_polaroid_cube_drive(monitor.get_connected_drives());

            Volume cube_volume = cube_drive.get_volumes().nth(0).data;

            Mount? mount = cube_volume.get_mount();
            if (mount == null) {
                throw new PolaroidCubeFinderError.CUBE_NOT_MOUNTED("The Polaroid CUBE drive is not mounted");
            }

            return mount.get_root();
	    }

        /**
        * Find the cube drive on a list of connected drives
        */
	    private static Drive find_polaroid_cube_drive(List<Drive> connectedDrives) throws PolaroidCubeFinderError {

	        foreach(Drive drive in connectedDrives) {
	            if (drive.get_name() == "Polaroid CUBE") {
	                return drive;
	            }
	        }
	        throw new PolaroidCubeFinderError.DRIVE_NOT_FOUND("Polaroid CUBE drive not found");
	    }
    }

    internal class SettingsWriter {
        private Regex property_matcher = /(\w*):(\w*)/;
        private File cube_root;

        internal SettingsWriter(File cube_root) {
            this.cube_root = cube_root;
        }

        internal void write(CubeSettings settings) throws Error {
            File settings_file_new = cube_root.get_child(NEW_SETTINGS_FILE_NAME);
            // delete if file already exists
            if (settings_file_new.query_exists ()) {
                settings_file_new.delete ();
            }

            File settings_file = cube_root.get_child(SETTINGS_FILE_NAME);
            var dis = new DataInputStream(settings_file.read());
            var output = new DataOutputStream(settings_file_new.create(FileCreateFlags.NONE));

            string line;
            bool in_comments = false;

            while ((line = dis.read_line(null)) != null) {
                if (line.has_prefix("--")) {
                    in_comments = true;
                }
                MatchInfo match;
                // all non-property lines are copied verbatim
                if (!property_matcher.match(line, 0, out match) || in_comments) {
                    output.put_string(@"$line\n");
                } else {
                    string property_name = match.fetch(1);
                    string property_value = property_name == "UPDATE" ? "Y" : settings.get(property_name);

                    output.put_string(@"$property_name:$property_value\n");
                }
            }

            File settings_file_bkup = cube_root.get_child(BKUP_SETTINGS_FILE_NAME);
            if (settings_file_bkup.query_exists ()) {
                settings_file_bkup.delete ();
            }
            settings_file.set_display_name(BKUP_SETTINGS_FILE_NAME);
            settings_file_new.set_display_name(SETTINGS_FILE_NAME);
        }
    }

	internal class SettingsReader {
        private File cube_root;

        internal SettingsReader(File cube_root) {
            this.cube_root = cube_root;
        }

	    internal CubeSettings read() throws Error {
            File settings_file = cube_root.get_child(SETTINGS_FILE_NAME);

            var dis = new DataInputStream(settings_file.read());

            // parse version from first line in file
            string version = parse_version(dis.read_line(null)._chomp());

            CubeSettings settings = CubeSettingsFactory.create(version);

            dis.read_line(null); // ignored UPDATE line
            dis.read_line(null); // ignored FORMAT line

            string line;

            while ((line = dis.read_line(null)) != null && !line.has_prefix("--")) {
                var property_parts = line.split(":");
                settings.set(property_parts[0], property_parts[1]._chomp());
                debug("setting property: %s: %s", property_parts[0], property_parts[1]._chomp());
            }

            return settings;
	    }

	    private string parse_version(string version_line) throws SettingFormatError {
	        string[] parts = version_line.split("-");
	        if (parts.length != 2) {
	            throw new SettingFormatError.VERSION_FORMAT
	                (@"wrong number of parts for version string: expected 2 got $(parts.length)");
	        }
	        return parts[1];
	    }
	}
}