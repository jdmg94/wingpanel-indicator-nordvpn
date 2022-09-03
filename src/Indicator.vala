public class NordVPN.Indicator : Wingpanel.Indicator {
  private NordVPN.Model nordvpn;
  private Gtk.Image display_widget;
  private NordVPN.PopOverWidget popover_widget;

  public Indicator () {
    Object (
      code_name: "wingpanel-nordvpn-indicator"
      );

    visible = true;
    nordvpn = new NordVPN.Model ();
  }

  public override void opened () {
    nordvpn.refresh_status ();
  }

  public override void closed () {}

  public override Gtk.Widget get_display_widget () {
    if (display_widget == null) {
      display_widget = new Gtk.Image.from_icon_name (
        nordvpn.state.is_connected ? "nordvpn-symbolic" : "nordvpn-off-symbolic",
        Gtk.IconSize.LARGE_TOOLBAR
        );

      display_widget.set_has_tooltip (true);
      nordvpn.state_changed.connect ((next_state) => {
        display_widget.tooltip_markup = derive_tooltip_markup (next_state);
        display_widget.icon_name = next_state.is_connected ? "nordvpn-symbolic" : "nordvpn-off-symbolic";
      });
    }

    return display_widget;
  }

  public override Gtk.Widget ? get_widget () {
    if (popover_widget == null) {
      popover_widget = new NordVPN.PopOverWidget (nordvpn);

      popover_widget.opened_dialog.connect (() => {
        this.close ();
      });
    }

    return popover_widget;
  }

  private string derive_tooltip_markup (NordVPN.State connection) {
    if (!connection.is_connected) {
      return connection.status;
    }

    StringBuilder status_tooltip = new StringBuilder ();
    string key_markup = "<b><span>%s:</span></b> ";
    status_tooltip.append (key_markup.printf ("Location"));
    status_tooltip.append ("%s, %s".printf (connection.city, connection.country));
    status_tooltip.append ("\n");
    status_tooltip.append (key_markup.printf ("Current Server"));
    status_tooltip.append (connection.current_server);
    status_tooltip.append ("\n");

    status_tooltip.append (key_markup.printf ("Server IP"));
    status_tooltip.append (connection.server_ip);
    status_tooltip.append ("\n");

    status_tooltip.append (key_markup.printf ("Current Protocol"));
    status_tooltip.append (connection.current_protocol);
    status_tooltip.append ("\n");

    status_tooltip.append (key_markup.printf ("Current Technology"));
    status_tooltip.append (connection.current_technology);

    return status_tooltip.str;
  }

}

public Wingpanel.Indicator ? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
  if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
    return null;
  }

  Notify.init ("dev.josemunoz.wingpanel-indicator-nordvpn");

  return new NordVPN.Indicator ();
}