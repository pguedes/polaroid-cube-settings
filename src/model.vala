namespace PolaroidCube.Model {

    public errordomain CubeSettingsFactoryError { UNSUPPORTED_VERSION, UNKNOWN_PROPERTY }

    const string LIGHT_FREQUENCY_PROPERTY = "LightFrequency";
    const string TIME_STAMP_PROPERTY = "TimeStamp";
    const string CYCLE_RECORDING_PROPERTY = "CycleRecord";
    const string BUZZER_VOLUME_PROPERTY = "BuzzerVolume";
    const string RECORDING_TIME_PROPERTY = "RecordingTime";
    const string BITRATE_PROPERTY = "Bitrate";
    const string SELF_TIMER_PROPERTY = "SelfTimer";

    public class CubeSettingsFactory {

        public static CubeSettings create(string version) throws CubeSettingsFactoryError {
            switch (version) {
                case "V1.01":
                    return new CubeSettings();
                case "V1.17":
                    return new CubeSettingsV1_17();
                default:
                    throw new CubeSettingsFactoryError.UNSUPPORTED_VERSION
                        (@"unsupported version of settings: $version");
            }
        }
    }

	public class CubeSettings {
	    public int light_frequency { get; set; }
	    public bool time_stamp { get; set; }
	    public bool cycle_recording { get; set; }
	    public int buzzer_volume { get; set; }

	    protected string get_property_string(string property, string value) {
	        return @"$property:$value";
	    }

	    public void set(string property, string value) {
	        switch(property) {
	            case LIGHT_FREQUENCY_PROPERTY:
	               this.light_frequency = int.parse(value);
	               break;
	            case TIME_STAMP_PROPERTY:
	               this.time_stamp = "1" == value;
	               break;
	            case CYCLE_RECORDING_PROPERTY:
	               this.cycle_recording = "1" == value;
	               break;
	            case BUZZER_VOLUME_PROPERTY:
	               this.buzzer_volume = int.parse(value);
	               break;
	        }
	    }

	    public string get(string property) throws CubeSettingsFactoryError {
	        switch(property) {
	            case LIGHT_FREQUENCY_PROPERTY:
	               return this.light_frequency.to_string();
	            case TIME_STAMP_PROPERTY:
	               return time_stamp ? "1" : "0";
	            case CYCLE_RECORDING_PROPERTY:
	               return this.cycle_recording ? "1" : "0";
	            case BUZZER_VOLUME_PROPERTY:
	               return this.buzzer_volume.to_string();
	        }
	        throw new CubeSettingsFactoryError.UNKNOWN_PROPERTY(property);
	    }

        public string to_string() {
            var builder = new StringBuilder ();
            builder.append(get_property_string(LIGHT_FREQUENCY_PROPERTY, this.light_frequency.to_string()));
            builder.append(get_property_string(TIME_STAMP_PROPERTY, this.time_stamp.to_string()));
            builder.append(get_property_string(CYCLE_RECORDING_PROPERTY, this.cycle_recording.to_string()));
            builder.append(get_property_string(BUZZER_VOLUME_PROPERTY, this.buzzer_volume.to_string()));
            return builder.str;
        }
	}

	public class CubeSettingsV1_17 : CubeSettings {
	    public int recording_time { get; set; }
	    public int bitrate { get; set; }
	    public int self_timer { get; set; }

        public new string to_string() {
            var builder = new StringBuilder ();

            builder.append(base.to_string());

            builder.append(get_property_string(RECORDING_TIME_PROPERTY, this.recording_time.to_string()));
            builder.append(get_property_string(BITRATE_PROPERTY, this.bitrate.to_string()));
            builder.append(get_property_string(SELF_TIMER_PROPERTY, this.self_timer.to_string()));

            return builder.str;
        }
	}
}