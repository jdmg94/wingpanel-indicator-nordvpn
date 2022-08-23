public class NordVPN.PopOverWidget : Gtk.Box {
  public signal void vpn_changed (bool is_active);

  private string current_key = "";

  public PopOverWidget (NordVPN.Model nordvpn) {
    NordVPN.State connection = nordvpn.state;
    RevealerSwitch connection_toggle = new RevealerSwitch (connection.status, nordvpn.is_connected);
    Gtk.Button settings_icon_button = new Gtk.Button.from_icon_name ("open-menu-symbolic", Gtk.IconSize.MENU);
    NordVPN.ServersTreeWidget servers_tree_view = new NordVPN.ServersTreeWidget (nordvpn.store, nordvpn.active_path);
    Gtk.Label connection_label = new Gtk.Label (connection.country + ", " + connection.city) {
      halign = Gtk.Align.START,
    };
    Gtk.Box row = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
      margin_top = 10,
      margin_bottom = 10,
      margin_end = 10,
    };

    connection_toggle.toggled.connect ((is_active) => {
      vpn_changed (is_active);
      connection_toggle.set_active (is_active);

      connection_toggle.text = is_active ? "Connected" : "Disconnected";
      if (is_active) {
        nordvpn.controller.connect (current_key);
      } else {
        nordvpn.controller.disconnect ();
      }
    });

    nordvpn.state_changed.connect ((next_state) => {
      connection_label.set_text (next_state.country + ", " + next_state.city);
    });

    connection_toggle.add (row);
    connection_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
    row.pack_start (connection_label, true, true, 0);
    row.pack_start (settings_icon_button, false, false, 0);

    settings_icon_button.clicked.connect (() => {
      var window = new NordVPN.SettingsView ();

      window.show ();
    });

    servers_tree_view.selection_changed.connect ((next_label, next_value, next_path) => {
      current_key = next_value;
      connection_label.set_text (next_label);

      if (nordvpn.is_connected) {
        nordvpn.controller.connect (next_value);
        nordvpn.active_path = next_path;
      }
    });

    this.pack_start (connection_toggle);
    this.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
    this.pack_start (servers_tree_view);

    this.set_margin_top (5);
    this.orientation = Gtk.Orientation.VERTICAL;
  }

  construct {
    show_all ();
  }
}