public class NordVPN.SettingsView : Gtk.Window {
  construct {
    resizable = false;
    title = "NordVPN Settings";
  }

  public SettingsView () {
    this.set_default_size (640, 480);
  }

  public void show () {
    this.visible = true;
  }

}