class NordVPN.RevealerSwitch : Gtk.Box {
  public signal void toggled (bool is_active);

  private Gtk.Revealer revealer;
  private Gtk.Box revealer_content;
  private Granite.SwitchModelButton main_switch;
  public string text {
    get {
      return this.main_switch.text;
    }
    set construct {
      this.main_switch.text = value;
    }
  }

  public RevealerSwitch (string title, bool defaultOpen = false, bool inverted = false) {
    this.orientation = Gtk.Orientation.VERTICAL;
    this.revealer_content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    this.main_switch = new Granite.SwitchModelButton (title) {
      active = defaultOpen
    };

    this.revealer = new Gtk.Revealer () {
      reveal_child = inverted ? !defaultOpen : defaultOpen
    };

    this.main_switch.toggled.connect ((nextState) => {
      toggled (nextState.active);
      this.revealer.reveal_child = inverted ? !nextState.active : nextState.active;
    });

    this.main_switch.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
    this.revealer_content.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
    this.revealer.add (revealer_content);
    this.pack_start (this.main_switch);
    this.pack_start (this.revealer);
  }

  construct {
    show_all ();
  }

  public new void add (Gtk.Widget child) {
    this.revealer_content.pack_start (child);
  }

  public void set_active(bool next_state) {
    this.main_switch.set_active(next_state);
  }

}