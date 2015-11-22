using PolaroidCube.Model;

namespace PolaroidCube.IO {

    errordomain SettingFormatError { VERSION_FORMAT }

    private const string SETTINGS_FILE_NAME = "Setting.txt";
    private const string NEW_SETTINGS_FILE_NAME = "Setting.txt.new";
    private const string BKUP_SETTINGS_FILE_NAME = "Setting.txt.bkup";

    public class SettingsWriter {
        private Regex property_matcher = /(\w*):(\w*)/;

        public void write(File cube_root, CubeSettings settings) throws Error {
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

	public class SettingsReader {

	    public CubeSettings read(File cube_root) throws Error {
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
                settings.set(property_parts[0], property_parts[1]);
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