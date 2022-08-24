public class NordVPN.InfoBar : Gtk.Box {
  private Gtk.Label connection_label;
  private Gtk.Button settings_icon_button;
  private NordVPN.State connection;

  public InfoBar (string label) {
    settings_icon_button = new Gtk.Button.from_icon_name ("open-menu-symbolic", Gtk.IconSize.MENU);
    connection_label = new Gtk.Label (label) {
      halign = Gtk.Align.START,
    };

    connection_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
    settings_icon_button.clicked.connect (() => {
      var window = new NordVPN.SettingsView ();

      window.show_all ();
    });

    this.pack_start (connection_label, true, true, 0);
    this.pack_start (settings_icon_button, false, false, 0);
  }

  construct {
    margin_top = 10;
    margin_bottom = 10;
    margin_end = 10;
    orientation = Gtk.Orientation.HORIZONTAL;
  }

  public void set_label (string next_label) {
    this.connection_label.set_text (next_label);
  }

}