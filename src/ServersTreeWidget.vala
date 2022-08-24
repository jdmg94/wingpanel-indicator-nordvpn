public class NordVPN.ServersTreeWidget : Gtk.Box {
  public signal void selection_changed (string next_label, string next_value, Gtk.TreePath next_path);

  private Gtk.SearchEntry search_bar;
  private Gtk.TreePath active_path;

  public ServersTreeWidget (Gtk.TreeStore nordvpn_model, Gtk.TreePath ? initial_path = null) {
    if (initial_path != null) {
      active_path = initial_path;

    }

    search_bar = new Gtk.SearchEntry ();

    Gtk.TreeView servers_tree_view = new Gtk.TreeView ();
    Gtk.ScrolledWindow scrolled = new Gtk.ScrolledWindow (null, null);
    Gtk.CellRendererText cell_renderer_text = new Gtk.CellRendererText ();
    Gtk.CellRendererToggle cell_renderer_radio = new Gtk.CellRendererToggle ();
    Gtk.TreeModelFilter filtered_model = new Gtk.TreeModelFilter (nordvpn_model, null);

    scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
    scrolled.max_content_height = 420;
    scrolled.propagate_natural_height = true;
    scrolled.add (servers_tree_view);

    search_bar.set_hexpand (true);
    search_bar.set_margin_top (10);
    search_bar.set_margin_end (5);
    search_bar.set_margin_start (5);
    search_bar.set_margin_bottom (10);
    search_bar.set_placeholder_text ("Search for servers...");

    this.orientation = Gtk.Orientation.VERTICAL;
    this.pack_start (search_bar);
    this.pack_start (scrolled);

    cell_renderer_radio.set_radio (true);
    cell_renderer_radio.set_alignment (0, 0);

    cell_renderer_text.ellipsize_set = true;
    cell_renderer_text.ellipsize = Pango.EllipsizeMode.END;

    servers_tree_view.set_tooltip_column (0);
    servers_tree_view.set_model (filtered_model);
    servers_tree_view.set_fixed_height_mode (true);
    servers_tree_view.insert_column_with_attributes (-1, "All Servers", cell_renderer_text, "text", 0, null);
    servers_tree_view.insert_column_with_attributes (-1, null, cell_renderer_radio, "active", 2, "visible", 1, null);

    servers_tree_view.expand_all ();
    servers_tree_view.get_column (0).set_expand (true);
    servers_tree_view.get_column (1).set_min_width (30);
    filtered_model.set_visible_func (this.filter_tree);

    search_bar.search_changed.connect (() => {
      filtered_model.refilter ();
      servers_tree_view.expand_all ();
    });

    cell_renderer_radio.toggled.connect ((next_path_string) => {
      GLib.Value buffer;
      Gtk.TreeIter iterator;
      string next_label = "";
      string next_value = "";
      Gtk.TreePath next_path = new Gtk.TreePath.from_string (next_path_string);

      if ((bool)active_path) {
        nordvpn_model.get_iter (out iterator, this.active_path);
        nordvpn_model.set_value (iterator, 2, false);
        set_parent (nordvpn_model, iterator, 2, false);

        if (active_path.to_string () != next_path.to_string ()) {
          this.active_path = next_path;
        }
      }


      nordvpn_model.get_iter (out iterator, next_path);
      nordvpn_model.set_value (iterator, 2, true);
      set_parent (nordvpn_model, iterator, 2, true);

      nordvpn_model.get_value (iterator, 3, out buffer);
      next_value = (string) buffer;

      nordvpn_model.get_value (iterator, 0, out buffer);
      next_label += (string) buffer;
      get_parent (nordvpn_model, iterator, 1, out buffer);
      if ((bool) buffer) {
        get_parent (nordvpn_model, iterator, 0, out buffer);
        next_label = (string) buffer + ", " + next_label;
      }

      selection_changed (next_label, next_value, next_path);
    });

  }

  private void get_parent (Gtk.TreeStore model, Gtk.TreeIter iterator, int column, out GLib.Value buffer) {
    Gtk.TreeIter iterator_parent;

    if (model.iter_parent (out iterator_parent, iterator)) {
      model.get_value (iterator_parent, column, out buffer);
    }
  }

  private void set_parent (Gtk.TreeStore model, Gtk.TreeIter iterator, int column, bool next_value) {
    Gtk.TreeIter iterator_parent;

    if (model.iter_parent (out iterator_parent, iterator)) {
      model.set_value (iterator_parent, column, next_value);
    }
  }

  private bool filter_tree (Gtk.TreeModel model, Gtk.TreeIter iterator) {
    GLib.Value buffer;
    model.get_value (iterator, 0, out buffer);

    string value = ((string) buffer).down ();
    string query = search_bar.get_text ().down ();
    bool result = value == query || value.contains (query);

    if (!result && model.iter_has_child (iterator)) {
      return lookup_children (model, iterator);
    }

    return result;
  }

  private bool lookup_children (Gtk.TreeModel model, Gtk.TreeIter iterator) {
    Gtk.TreeIter child_iterator;
    model.iter_children (out child_iterator, iterator);

    bool result = false;

    do {
      result = filter_tree (model, child_iterator);

      if (result) {
        break;
      }
    } while (model.iter_next (ref child_iterator));

    return result;
  }

  public void set_active_path (Gtk.TreePath next_path) {
    this.active_path = next_path;
  }
}