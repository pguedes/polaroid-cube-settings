using Gtk;
using PolaroidCube.Model;

namespace PolaroidCube.UI {

	public class SettingsGUI {

	    private ToggleButton light_fifty_button;
	    private ToggleButton light_sixty_button;

	    private CubeSettings settings;

        public Window window { get; set; }

        /**
        * Signal to save the settings
        */
	    public signal void save_settings(CubeSettings settings);

	    public SettingsGUI(CubeSettings cube_settings) throws Error {
	        this.settings = cube_settings;
	        build_window();
	    }

        /**
        * Load the GUI from the Glade file and connect signal handlers.
        */
        private void build_window() throws Error {
            var builder = new Builder();

            builder.add_from_resource("/pt/PolaroidCube/polaroid-cube-settings-window.glade");

            this.window = builder.get_object("window") as Window;
            this.light_fifty_button = builder.get_object("light_fifty") as ToggleButton;
            this.light_sixty_button = builder.get_object("light_sixty") as ToggleButton;

            var activeLightButton =
                this.settings.light_frequency == 1 ? this.light_fifty_button : this.light_sixty_button;
            activeLightButton.active = true;

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
            this.settings.time_stamp = active;
            return false;
        }

        // polaroid_cube_ui_settings_gui_init_timestamp
        [CCode (instance_pos = -1)]
        public bool init_timestamp(Switch it) {
            it.set_active(this.settings.time_stamp);
            return false;
        }

        // polaroid_cube_ui_settings_gui_change_cycle_recording
        [CCode (instance_pos = -1)]
        public bool change_cycle_recording(Switch it, bool active) {
            this.settings.cycle_recording = active;
            return false;
        }

        // polaroid_cube_ui_settings_gui_init_cycle_recording
        [CCode (instance_pos = -1)]
        public bool init_cycle_recording(Switch it) {
            it.set_active(this.settings.cycle_recording);
            return false;
        }

        // polaroid_cube_ui_settings_gui_update_buzzer_volume
        [CCode (instance_pos = -1)]
        public bool update_buzzer_volume(Adjustment adjustment) {
            this.settings.buzzer_volume = (int)adjustment.value;
            return false;
        }

        // polaroid_cube_ui_settings_gui_init_buzzer_volume
        [CCode (instance_pos = -1)]
        public bool init_buzzer_volume(Scale adjustment) {
            adjustment.set_value(this.settings.buzzer_volume);
            return false;
        }

        // polaroid_cube_ui_settings_gui_on_save
        [CCode (instance_pos = -1)]
        public void on_save(Button source) {
            this.save_settings(this.settings);
        }

        public SettingsGUI show(){
            this.window.show_all();
            return this;
        }
	}
}