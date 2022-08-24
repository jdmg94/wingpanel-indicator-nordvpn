public class NordVPN.PopOverWidget : Gtk.Box {
  private string current_key = "";
  private NordVPN.InfoBar info_bar;
  private RevealerSwitch connection_toggle;

  public PopOverWidget (NordVPN.Model nordvpn) {
    NordVPN.State connection = nordvpn.state;
    NordVPN.ServersTreeWidget servers_tree_view = new NordVPN.ServersTreeWidget (nordvpn.store, nordvpn.active_path);

    this.connection_toggle = new RevealerSwitch (connection.status, connection.is_connected);
    this.info_bar = new NordVPN.InfoBar ("%s, %s".printf (connection.country, connection.city));

    this.set_margin_top (5);
    this.orientation = Gtk.Orientation.VERTICAL;
    this.pack_start (connection_toggle);
    this.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
    this.pack_start (servers_tree_view);

    update_connection_label (connection);

    connection_toggle.add (info_bar);
    connection_toggle.toggled.connect ((is_active) => {
      connection_toggle.text = is_active ? "Connected" : "Disconnected";
      if (is_active) {
        nordvpn.controller.connect (current_key);
      } else {
        nordvpn.controller.disconnect ();
      }
    });

    nordvpn.state_changed.connect (update_connection_label);
    servers_tree_view.selection_changed.connect ((next_label, next_value, next_path) => {
      current_key = next_value;

      if (connection.is_connected) {
        nordvpn.controller.connect (next_value);
        nordvpn.active_path = next_path;
      }
    });
  }

  construct {
    show_all ();
  }

  private void update_connection_label (NordVPN.State next_state) {
    info_bar.set_label ("%s, %s".printf (next_state.country, next_state.city));
  }

}