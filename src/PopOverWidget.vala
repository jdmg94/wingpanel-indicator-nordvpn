public class NordVPN.PopOverWidget : Gtk.Box {
  public signal void vpn_changed (bool is_active);

  public PopOverWidget (NordVPN.Controller nordvpn) {
    NordVPN.State connection = nordvpn.get_state ();
    RevealerSwitch connection_toggle = new RevealerSwitch (connection.status, connection.status == "Connected");

    connection_toggle.toggled.connect ((is_active) => {
      vpn_changed (is_active);

      connection_toggle.text = is_active ? "Connected" : "Disconnected";
    });

    var settings_icon_button = new Gtk.Button.from_icon_name ("open-menu-symbolic", Gtk.IconSize.MENU);
    var connection_label = new Gtk.Label (connection.country + ", " + connection.city) {
      halign = Gtk.Align.START,
    };

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
      var window = new Gtk.Window () {
        resizable = false,
        title = "NordVPN Settings"
      };

      window.show_all ();
    });

    Gtk.TreeStore nordvpn_model = nordvpn.get_all_connection_options ();
    NordVPN.ServersTreeView servers_tree_view = new NordVPN.ServersTreeView (nordvpn_model);



    this.pack_start (connection_toggle);
    this.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
    this.pack_start (servers_tree_view);

    this.set_margin_top (5);
    this.set_margin_bottom (5);
    this.orientation = Gtk.Orientation.VERTICAL;

  }

  construct {
    show_all ();
  }
}