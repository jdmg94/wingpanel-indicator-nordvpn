public class NordVPN.SettingsView : Granite.Dialog {
  construct {
    resizable = false;
    default_width = 550;
    title = "NordVPN Settings";
    icon_name = "nordvpn-symbolic";
  }

  private NordVPN.Model model;

  public SettingsView (NordVPN.Model nordvpn) {
    model = nordvpn;

    Gtk.Grid layout = new Gtk.Grid ();
    var logout_button = new Gtk.Button.with_label ("Logout");
    Gtk.Box controls = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    Gtk.Box row_logo = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    Gtk.Image NordVPN_logo = new Gtk.Image.from_icon_name ("nordvpn-logo-symbolic", Gtk.IconSize.DIALOG);
    Gtk.LinkButton author_link = new Gtk.LinkButton.with_label ("https://josemunoz.dev", "Unofficially Made by José Muñoz 🇭🇳");
    /* *INDENT-OFF* */
    GLib.Regex ip_list_schema = /((25[0-5]|2[0-4]\d|[01]?\d\d?)\.(25[0-5]|2[0-4]\d|[01]?\d\d?)\.(25[0-5]|2[0-4]\d|[01]?\d\d?)\.(25[0-5]|2[0-4]\d|[01]?\d\d?)(,\n|,?$))/;
    /* *INDENT-ON* */
    Gtk.Label account_info = new Gtk.Label (nordvpn.controller.get_account_information ()) {
      halign = Gtk.Align.CENTER,
      valign = Gtk.Align.CENTER,
    };

    Gtk.ComboBox protocols_combobox = get_combobox (
      nordvpn.settings.protocols,
      index_of (nordvpn.settings.protocols, nordvpn.state.current_protocol)
      );

    Gtk.ComboBox technology_combobox = get_combobox (
      nordvpn.settings.technologies,
      index_of (nordvpn.settings.technologies, nordvpn.state.current_technology)
      );

    Gtk.Box protocol_select = get_label_row (
      "Protocol",
      protocols_combobox
      );

    Gtk.Box technology_select = get_label_row (
      "Technology",
      technology_combobox
      );

    Granite.ValidatedEntry dns_input = new Granite.ValidatedEntry.from_regex (ip_list_schema) {
      text = string.joinv (", ", nordvpn.settings.dns) ?? ""
    };

    Gtk.Box dns_entry = get_label_row (
      "DNS Servers",
      dns_input
      );

    protocols_combobox.set_sensitive (nordvpn.state.current_technology == "OPENVPN");

    protocols_combobox.changed.connect (() => {
      string next_value = get_current_combobox_value (technology_combobox);

      update_property ("protocol", next_value);
    });

    technology_combobox.changed.connect (() => {
      string next_value = get_current_combobox_value (technology_combobox);

      protocols_combobox.set_sensitive (next_value == "OPENVPN");

      update_property ("technology", next_value);
    });

    dns_input.activate.connect (() => {
      string buffer = dns_input.get_text ();

      if (dns_input.is_valid) {
        update_property ("dns", buffer.replace (",", " "));
      } else if (buffer.length == 0) {
          update_property ("dns", "disabled");
      }
    });

    account_info.set_padding (10, 0);
    NordVPN_logo.set_pixel_size (0);
    NordVPN_logo.set_halign (Gtk.Align.CENTER);
    row_logo.pack_start (NordVPN_logo, false, false, 0);
    row_logo.pack_start (account_info, true, true, 0);

    controls.pack_start (dns_entry);
    controls.pack_start (technology_select);
    controls.pack_start (protocol_select);

    Touple<string>[] labels = {
      new Touple<string>("Auto Connect", "autoconnect"),
      new Touple<string>("Kill Switch", "kill_switch"),
      new Touple<string>("Firewall", "firewall"),
      new Touple<string>("Threat Protection Lite", "threat_protection_lite"),
    };

    foreach (unowned Touple<string> label in labels) {
      string current_state;
      string key = label.get (1);
      nordvpn.settings.get (key, out current_state);
      Granite.SwitchModelButton tmp = new Granite.SwitchModelButton (label.get (0)) {
        margin_start = 10,
        margin_end = 10,
        margin_bottom = 10,
        active = (current_state == "enabled"),
      };


      tmp.toggled.connect ((next_state) => {
        update_property (
          key.replace ("_", ""),
          next_state.get_active () ? "on" : "off"
          );
      });

      controls.pack_start (tmp);
    }

    layout.attach (row_logo, 0, 0);
    layout.attach (controls, 0, 2);
    controls.pack_start (author_link);

    this.get_content_area ().add (layout);
    this.add_button ("Close", Gtk.ResponseType.CLOSE);
    this.response.connect ((response_type) => {
      if (response_type == Gtk.ResponseType.CLOSE) {
        this.destroy ();
      }
    });
  }

  private Gtk.ListStore derive_store (string[] data) {
    Gtk.TreeIter iterator;
    Gtk.ListStore result = new Gtk.ListStore (1, typeof (string));

    foreach (unowned string value in data) {
      result.append (out iterator);
      result.set (iterator, 0, value, -1);
    }

    return result;
  }

  private Gtk.ComboBox get_combobox (string[] data, int ? active_index = 0) {
    Gtk.ComboBox combobox_widget = new Gtk.ComboBox ();
    Gtk.CellRendererText renderer = new Gtk.CellRendererText ();

    combobox_widget.set_model (derive_store (data));
    combobox_widget.set_active (active_index);
    combobox_widget.pack_start (renderer, true);
    combobox_widget.add_attribute (renderer, "text", 0);

    return combobox_widget;
  }

  private Gtk.Box get_label_row (string label, Gtk.Widget action_widget) {
    Gtk.Box container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
    Gtk.Label label_widget = new Gtk.Label (label) {
      halign = Gtk.Align.START
    };

    container.set_margin_bottom (10);
    container.set_margin_start (10);
    container.set_margin_end (10);
    container.set_vexpand (false);
    container.pack_start (label_widget, true, true, 0);
    container.pack_start (action_widget, false, false, 0);

    return container;
  }

  private int index_of (string[] data, string value) {
    for (int i = 0 ; i < data.length ; i++) {
      if (data[i] == value) {
        return i;
      }
    }

    return -1;
  }

  private void update_property (string key, string value) {
    model.controller.update_setting (key, value);
  }

  private string get_current_combobox_value (Gtk.ComboBox widget) {
    string result = "";
    Gtk.TreeIter iterator;
    Gtk.TreeModel model = widget.get_model ();

    if (widget.get_active_iter (out iterator)) {
      model.get (iterator, 0, out result, -1);
    }

    return result;
  }

}