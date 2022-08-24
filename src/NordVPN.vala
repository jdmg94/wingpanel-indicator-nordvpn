public class NordVPN.State : GLib.Object {
  public bool is_connected;
  public string status { get; set; default = "Disconnected"; }
  public string country { get; set; }
  public string city { get; set; }
  public string current_server { get; set; }
  public string server_ip { get; set; }
  public string current_technology { get; set; }
  public string current_protocol { get; set; }
  public string uptime { get; set; }
  public string transfer { get; set; }

  public State () {}
}

public class NordVPN.Settings : GLib.Object {
  public string technology { get; set; }
  public string firewall { get; set; }
  public string kill_switch { get; set; }
  public string threat_protection { get; set; }
  public string notifications { get; set; }
  public string auto_connect { get; set; }
  public string ipv6 { get; set; }
  public string meshnet { get; set; }
  public string dns { get; set; }
  public string whitelisted_subnets { get; set; }

  public Settings () {}
}

public class NordVPN.Touple<T> {
  private T[] data;
  public Touple (T a, T b = null, T c = null) {
    data = new T[] {
      a,
      b,
      c,
    };
  }

  public T get (int index) {
    if (index < 3) {
      return this.data[index];
    }

    return null;
  }

}

public class NordVPN.Controller {
  public signal void connection_changed ();

  public Controller () {}

  private string MESH_WARNING = "New feature - Meshnet! Link remote devices in Meshnet to connect to them directly over encrypted private tunnels, and route your traffic through another device. Use the `nordvpn meshnet --help` command to get started. Learn more: https://nordvpn.com/features/meshnet/";
  private string sanitize (string value) {
    string buffer = value;
    string[] chars_to_remove = { MESH_WARNING, "\\r", "\\n", "-" };

    foreach (unowned string item in chars_to_remove) {
      buffer = buffer.replace (item, "");
    }


    return buffer.strip ();
  }

  public void connect (string ? server = "") {
    Posix.system ("nordvpn c " + server);
    connection_changed ();
  }

  public void disconnect () {
    Posix.system ("nordvpn d");
    connection_changed ();
  }

  public NordVPN.State get_state () {
    string buffer;
    NordVPN.State result = new NordVPN.State ();
    Process.spawn_command_line_sync ("nordvpn status", out buffer, null, null);

    if (buffer.contains (MESH_WARNING)) {
      string sanitized = this.sanitize (buffer);
      string[] parts = sanitized.split ("\n");

      foreach (unowned string item in parts) {
        string[] key_value_country = item.split (":");
        string key = key_value_country[0].down ().replace (" ", "_");
        string value = key_value_country[1].strip ();

        result.set (key, value);
      }

      result.is_connected = result.status == "Connected";

    }

    return result;
  }

  public NordVPN.Touple<string>[] get_request (string cmd) {
    string buffer;
    NordVPN.Touple<string>[] result = {};
    Process.spawn_command_line_sync (cmd, out buffer, null, null);

    if (buffer.contains (MESH_WARNING)) {
      string sanitized = this.sanitize (buffer);

      foreach (string item in sanitized.split (",")) {
        var tmp = item.strip ();
        result += new NordVPN.Touple<string>(tmp.replace ("_", " "), tmp);
      }

    }

    return result;
  }

  public NordVPN.Touple<string>[] get_groups () {

    return this.get_request ("nordvpn groups");
  }

  public NordVPN.Touple<string>[] get_countries () {

    return this.get_request ("nordvpn countries");
  }

  public NordVPN.Touple<string>[] get_cities (string country) {

    return this.get_request ("nordvpn cities " + country);
  }

}

public class NordVPN.Model : GLib.Object {
  public signal void state_changed (NordVPN.State next_state);

  private NordVPN.Settings settings;
  public NordVPN.Controller controller;
  public NordVPN.State state;
  public Gtk.TreeStore store;
  public Gtk.TreePath active_path { get; set; default = null; }

  public Model () {
    this.settings = new NordVPN.Settings ();
    this.controller = new NordVPN.Controller ();
    this.controller.connection_changed.connect (() => {
      this.refresh_status ();
    });

    this.refresh_status ();
    this.store = this.get_all_connection_options ();
  }

  public void refresh_status () {
    var next_state = this.controller.get_state ();

    this.state = next_state;
    this.state_changed (next_state);
  }

  private Gtk.TreeStore get_all_connection_options () {
    Gtk.TreeIter root;
    Gtk.TreeStore store = new Gtk.TreeStore (4,
                                             typeof (string), // label
                                             typeof (bool), //   is_visible
                                             typeof (bool), //   is_active
                                             typeof (string) //  value
                                             );

    // Adds Groups
    store.append (out root, null);
    store.set (root, 0, "Specialty Servers", 1, false, -1);
    Gtk.TreeIter groups_iterator;

    foreach (Touple<string> group in this.controller.get_groups ()) {
      store.append (out groups_iterator, root);
      store.set (groups_iterator,
                 0, group.get (0),
                 1, true,
                 2, false,
                 3, group.get (1),
                 -1
                 );
    }

    // Adds Countries
    store.append (out root, null);
    store.set (root, 0, "Locations", 1, false, -1);
    Gtk.TreeIter country_iterator;

    foreach (Touple<string> country in this.controller.get_countries ()) {
      bool country_is_active = state.is_connected && country.get (0) == this.state.country;

      store.append (out country_iterator, root);
      store.set (country_iterator,
                 0, country.get (0),
                 1, true,
                 2, country_is_active,
                 3, country.get (1),
                 -1
                 );

      if (country_is_active) {
        this.active_path = store.get_path (country_iterator);
      }

      // Add Cities
      Touple<string>[] cities = this.controller.get_cities (country.get (1));
      if (cities.length > 1) {
        Gtk.TreeIter cities_iterator;
        foreach (Touple<string> city in cities) {
          bool city_is_active = state.is_connected && city.get (0) == this.state.city;
          store.append (out cities_iterator, country_iterator);
          store.set (cities_iterator,
                     0, city.get (0),
                     1, true,
                     2, city_is_active,
                     3, city.get (1),
                     -1
                     );

          if (city_is_active) {
            this.active_path = store.get_path (cities_iterator);
          }
        }
      }

    }

    return store;
  }

}