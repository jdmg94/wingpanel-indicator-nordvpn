public class NordVPN.PopOverWidget : Gtk.Box {
  public signal void vpn_changed (bool is_active);

  public PopOverWidget (NordVPN.Model nordvpn) {
    NordVPN.State connection = nordvpn.state;
    RevealerSwitch connection_toggle = new RevealerSwitch (connection.status, nordvpn.is_connected);
    Gtk.Label connection_label = new Gtk.Label (connection.country + ", " + connection.city) {
      halign = Gtk.Align.START,
    };

    connection_toggle.toggled.connect ((is_active) => {
      vpn_changed (is_active);

      connection_toggle.text = is_active ? "Connected" : "Disconnected";
      if (is_active) {
        
      } else {
        nordvpn.controller.disconnect();
      }
    });

    nordvpn.state_changed.connect((next_state) => {
      connection_label.set_text(next_state.country + ", " + next_state.city);
    });

    var settings_icon_button = new Gtk.Button.from_icon_name ("open-menu-symbolic", Gtk.IconSize.MENU);
    

    var row = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
      margin_top = 10,
      margin_bottom = 10,
      margin_end = 10,
    };

    connection_toggle.add (row);
    connection_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
    row.pack_start (connection_label, true, true, 0);
    row.pack_start (settings_icon_button, false, false, 0);

    settings_icon_button.clicked.connect (() => {
      var window = new NordVPN.SettingsView ();

      window.show ();
    });

    NordVPN.ServersTreeWidget servers_tree_view = new NordVPN.ServersTreeWidget (nordvpn.store);



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