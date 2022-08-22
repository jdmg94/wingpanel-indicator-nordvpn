public class NordVPN.Indicator : Wingpanel.Indicator {
  private Gtk.Image display_widget;
  private NordVPN.PopOverWidget popover_widget;
  private NordVPN.Controller nordvpn;

  public Indicator () {
    Object (
      code_name: "wingpanel-nordvpn-indicator"
      );

    visible = true;
    nordvpn = new NordVPN.Controller ();
  }

  public override void opened () {}

  public override void closed () {}

  public override Gtk.Widget get_display_widget () {
    if (display_widget == null) {
      NordVPN.State connection = nordvpn.get_state ();
      bool is_active = connection.status == "Connected";
      
      display_widget = new Gtk.Image.from_icon_name (
        is_active ? "nordvpn-original-symbolic" : "nordvpn-positive-symbolic",
        Gtk.IconSize.LARGE_TOOLBAR
        );
    }

    return display_widget;
  }

  public override Gtk.Widget ? get_widget () {
    if (popover_widget == null) {
      popover_widget = new NordVPN.PopOverWidget (nordvpn);

      popover_widget.vpn_changed.connect ((is_active) => {
        display_widget.icon_name = is_active ? "nordvpn-original-symbolic" : "nordvpn-positive-symbolic";
      });

    }

    return popover_widget;
  }

}

public Wingpanel.Indicator ? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
  if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
    return null;
  }

  return new NordVPN.Indicator ();
}