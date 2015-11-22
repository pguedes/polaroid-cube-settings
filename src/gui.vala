using Gtk;
using PolaroidCube.Model;

namespace PolaroidCube.UI {

	public class SettingsGUI {

	    private Window window;
	    private ToggleButton light_fifty_button;
	    private ToggleButton light_sixty_button;

	    private CubeSettings settings;

        /**
        * Signal to save the settings
        */
	    public signal void save_settings(CubeSettings settings);

	    public SettingsGUI(CubeSettings cube_settings) throws Error {
	        build_window();
	        this.settings = cube_settings;
	    }

        /**
        * Load the GUI from the Glade file and connect signal handlers.
        */
        private void build_window() throws Error {
            var builder = new Builder();

            builder.add_from_file("polaroid-cube-settings-window.glade");

            this.window = builder.get_object("window") as Window;
            this.light_fifty_button = builder.get_object("light_fifty") as ToggleButton;
            this.light_sixty_button = builder.get_object("light_sixty") as ToggleButton;

            window.destroy.connect(Gtk.main_quit);
            builder.connect_signals(this);
        }

        // polaroid_cube_ui_settings_gui_toggle_fifty
        [CCode (instance_pos = -1)]
        public bool toggle_fifty(ToggleButton fifty) {
            this.light_sixty_button.active = !fifty.active;
            this.settings.light_frequency = fifty.active ? 1 : 0;
            return false;
        }

        // polaroid_cube_ui_settings_gui_toggle_sixty
        [CCode (instance_pos = -1)]
        public bool toggle_sixty(ToggleButton sixty) {
            this.light_fifty_button.active = !sixty.active;
            this.settings.light_frequency = sixty.active ? 0 : 1;
            return false;
        }

        // polaroid_cube_ui_settings_gui_change_timestamp
        [CCode (instance_pos = -1)]
        public bool change_timestamp(Switch it, bool active) {
            stdout.printf("updating state: %s\n", active.to_string());
            this.settings.time_stamp = active;
            return false;
        }

        // polaroid_cube_ui_settings_gui_change_cycle_recording
        [CCode (instance_pos = -1)]
        public bool change_cycle_recording(Switch it, bool active) {
            stdout.printf("updating cycle recording state: %s\n", active.to_string());
            this.settings.cycle_recording = active;
            return false;
        }

        // polaroid_cube_ui_settings_gui_update_buzzer_volume
        [CCode (instance_pos = -1)]
        public bool update_buzzer_volume(Adjustment adjustment) {
            this.settings.buzzer_volume = (int)adjustment.value;
            return false;
        }

        // polaroid_cube_ui_settings_gui_on_save
        [CCode (instance_pos = -1)]
        public void on_save(Button source) {
            this.save_settings(this.settings);
        }

        public void show(){
            this.window.show_all ();
        }
	}
}