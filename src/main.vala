using PolaroidCube.Model;
using PolaroidCube.IO;
using Gtk;
using PolaroidCube.UI;

namespace PolaroidCube {

	public class Main {

	    public static int main(string[] args) {
	        Gtk.init(ref args);

            try {
	            Cube cube = Cube.get();

                var settings = cube.read_settings();
	            debug("loaded settings is %s", settings.to_string());

                var window = new SettingsGUI(settings).show();

                window.save_settings.connect((settings) => {
                    try {
                        cube.update_settings(settings);
                    } catch (Error e) {
                        critical("Failed to update settings: %s", e.message);
                    }
                    debug("updated settings: %s", settings.to_string());
                } );

                Gtk.main();
            } catch (Error e) {
                critical("Failed to initialize UI: %s", e.message);
                return 1;
            }
            return 0;
	    }
	}
}