public class NordVPN.ServersTreeView : Gtk.Box {
  private string current_selection;
  private Gtk.SearchEntry search_bar;

  public ServersTreeView (Gtk.TreeStore nordvpn_model) {
    search_bar = new Gtk.SearchEntry ();

    Gtk.TreeView servers_tree_view = new Gtk.TreeView ();
    Gtk.TreeModelFilter filtered_model = new Gtk.TreeModelFilter (nordvpn_model, null);

    Gtk.ScrolledWindow scrolled = new Gtk.ScrolledWindow (null, null);
    Gtk.CellRendererText cell_renderer_text = new Gtk.CellRendererText ();
    Gtk.CellRendererToggle cell_renderer_radio = new Gtk.CellRendererToggle ();

    scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
    scrolled.max_content_height = 500;
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
    cell_renderer_radio.set_padding (10, 0);

    cell_renderer_text.ellipsize_set = true;
    cell_renderer_text.ellipsize = Pango.EllipsizeMode.END;

    servers_tree_view.expand_all ();
    servers_tree_view.set_tooltip_column (0);
    servers_tree_view.set_model (filtered_model);
    servers_tree_view.set_fixed_height_mode (true);
    servers_tree_view.insert_column_with_attributes (-1, "All Servers", cell_renderer_text, "text", 0, null);
    servers_tree_view.insert_column_with_attributes (-1, null, cell_renderer_radio, "active", 2, null);


    servers_tree_view.expand_all ();
    servers_tree_view.get_column (0).set_expand (true);
    filtered_model.set_visible_func (this.filter_tree);

    search_bar.search_changed.connect (() => {
      filtered_model.refilter ();
      servers_tree_view.expand_all ();
    });

    cell_renderer_radio.toggled.connect ((path) => {
      GLib.Value prev_state;
      Gtk.TreeIter iterator;

      if (this.current_selection != null) {
        nordvpn_model.get_iter (out iterator, new Gtk.TreePath.from_string (this.current_selection));
        nordvpn_model.set_value (iterator, 2, false);
      }

      if (this.current_selection != path) {
        this.current_selection = path;
      }

      nordvpn_model.get_iter (out iterator, new Gtk.TreePath.from_string (path));
      nordvpn_model.get_value (iterator, 2, out prev_state);
      nordvpn_model.set_value (iterator, 2, !(bool) prev_state);
    });

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

}