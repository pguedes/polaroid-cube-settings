using PolaroidCube.Model;
using PolaroidCube.IO;
using Gtk;
using PolaroidCube.UI;

namespace PolaroidCube {

	public class Main {

	    public static int main(string[] args) {
	        Gtk.init(ref args);

	        SettingsGUI gui = null;

            try {
	            Cube cube = Cube.get();

                var settings = cube.read_settings();
	            debug("loaded settings is %s", settings.to_string());

                gui = new SettingsGUI(settings).show();

                gui.save_settings.connect((settings) => {
                    try {
                        cube.update_settings(settings);
                        debug("updated settings: %s", settings.to_string());
                    } catch (Error e) {
                        show_error_dialog(gui.window, @"Failed to update settings: $(e.message)");
                        critical("Failed to update settings: %s", e.message);
                    }
                } );

            } catch (Error e) {
                show_error_dialog(gui != null ? gui.window : null, e.message);
                critical("Error: %s", e.message);
            }

            Gtk.main();

            return 0;
	    }

	    private static void show_error_dialog(Window? window, string message) {
            MessageDialog msg = new MessageDialog(window ?? new Window(), DialogFlags.MODAL, MessageType.ERROR,
                ButtonsType.OK, "%s", message);
            msg.response.connect(() => {
                msg.destroy();
                if (window == null) {
                    Gtk.main_quit();
                }
            });
            msg.show();
	    }
	}
}